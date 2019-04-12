#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FONT.CH"

/*/{Protheus.doc} SIFINR03
//Impressao de Boleto Bancario - Caixa Economica Federal

@author 	Leonardo Soncin
@since		23/01/12
@version 	P12.1.17
@obs 		Criado para CNI
@history  	27/04/17, Luciano Camargo - TOTVS, Melhorias/Adaptações: ProtheusDoc/ CEF para FIEB  
@history  	24/05/17, Kley@TOTVS, Melhorias/Adaptações: ProtheusDoc/ CEF para FIEB  
@history  	08/03/18, Kley@TOTVS, Inclusão do banco SICOOB para FIEMG  
@type 		function

/*/

User Function SIFINR03()

	Local oDlg 		:= NIL
	Local oProcess 	:= NIL
	Local cPerg 	:= "SIFR03"
	Local nOpc		:= 0

	Private cCodBanco	:= ""
	Private cDVBanco	:= ""
	Private aRadio  	:= {}
	Private nRadio 		:= 1
	Private oRadio  	:= Nil 
	Private cbmp_caixa	:= GetMV("SI_LOGOBOL")
	Private cbmp_sicoob	:= GetMV("SI_LOGOSIC")
	Private cbmp_brasil	:= GetMV("SI_LOGOBBR")
	//Private _BcoBol     := GetNewPar("SI_BCOBOL"  , "104/001")  // 27/04/17 Luciano Camargo - TOTVS - Parametro que contem a relação dos bancos que serão utilizados no Boleto
	Private _VersoBol   := GetNewPar("SI_VERSOBOL", "0")    // 27/04/17 Luciano Camargo - TOTVS - 0=Impressão Verso Desabilitada / 1=Impressão verso Habilitada

	// Add em MENU os bancos que serão utilizados
	//If "104" $ _BcoBol
	aAdd( aRadio, {"Caixa Econôm. Federal","104","0"} )
	//Endif
	//If "341" $ _BcoBol
	//	aAdd( aRadio, {"Banco Itaú SA","341","7"} )                                             
	//Endif
	//If "001" $ _BcoBol
	aAdd( aRadio, {"Banco do Brasil","001","9"} )
	//Endif
	/*If "033" $ _BcoBol
	aAdd( aRadio, {"Santander","033","7"} )
	Endif
	If "041" $ _BcoBol
	aAdd( aRadio, {"Banrisul","041","8"} )
	Endif*/
	//If "756" $ _BcoBol
	aAdd( aRadio, {"SICOOB","756","0"} )
	//Endif*/

	ValidPerg(cPerg)

	DEFINE MSDIALOG oDlg FROM 0,0 TO 158,280 PIXEL TITLE "      Selecione o Banco      [v12.1.17]"

	@ 003,005 TO 060,135 LABEL "" OF oDlg PIXEL
	@ 008,008 RADIO oRadio VAR nRadio ITEMS aRadio[1][1], aRadio[2][1], aRadio[3][1] SIZE 070,009 PIXEL OF oDlg	// Ao acrescentar novos bancos esta lista deve ser manipulada

	DEFINE SBUTTON FROM 065,071 TYPE 1 OF oDlg ENABLE ONSTOP "Confirmar" ACTION (nOpc:=1,oDlg:End())
	DEFINE SBUTTON FROM 065,107 TYPE 2 OF oDlg ENABLE ONSTOP "Sair" ACTION (nOpc:=0,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTER

	If nOpc == 1

		cCodBanco	:= aRadio[nRadio][2]
		cDVBanco	:= aRadio[nRadio][3]

		If Pergunte(cPerg,.t.) //PAULO-->.and. u_FIN03ini()//.and. U_FINR03VB()
				oProcess := MsNewProcess():New( { | lEnd | Imprime( @lEnd,oProcess ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
				oProcess:Activate()
			
		Endif

	Endif

Return

/*/{Protheus.doc} Imprime
//Funcao STATIC impressão boleto

@author 	luciano.camargo
@since 		27/04/2017
@version 	P11.8
@param 		lEnd, logical, descricao
@param 		oProcess, object, descricao
@type 		function

/*/

Static Function Imprime(lEnd,oProcess)

	Local cQuery 	:= ""
	Local cAliasTMP	 := GetNextAlias()
	Local cAliasTRB := GetNextAlias()
	Local cNomArqTrb:= ""
	Local nTotRegs 	:= 0
	Local nProcRegs := 0
	Local aEstrut 	:= SE1->(dbStruct())
	Local lRet      := .T. // inserido por carlos queiroz e felipe queiroz em 19/06/13
	Local nOpc 		:= 0
	Local aCampos	:= {}
	Local nI, nCntFOr
	Local oDlg
	Local oChk
	Local oInv
	Local oMark
	Local _cVctoIni, _cVctoFim

	Private lInverte:= .F.
	Private cMarca  := GetMark()
	Private lTodos  := .T.
	Private lChang  := .T.
	Private oPrn    := NIL

	Private oFont1	:= TFont():New(     "Arial",,13.5,,.T./*Bold*/,,,,,.F./*Underline*/)
	Private oFont2 	:= TFont():New(     "Arial",,13,,.T.,,,,,.F.)
	Private oFont3	:= TFont():New(     "Arial",, 6,,.F.,,,,,.F.)
	Private oFont4	:= TFont():New(     "Arial",, 8,,.F.,,,,,.F.)
	Private oFont5 	:= TFont():New(   "Courier",, 6,,.T.,,,,,.F.)
	Private oFont6 	:= TFont():New(     "Arial",, 8,,.T.,,,,,.F.)
	Private oFont7 	:= TFont():New(     "Arial",,18,,.t.,,,,,.f. )
	Private oFont8	:= TFont():New(     "Arial",,14,,.t.,,,,,.f. )
	Private oFont9	:= TFont():New(     "Arial",, 9,,.F.,,,,,.F.)
	Private oFont10	:= TFont():New(     "Arial",, 9,,.T.,,,,,.F.)
	Private oFont11	:= TFont():New(     "Arial",, 7,,.F.,,,,,.F.)
	Private oFont12	:= TFont():New(   "Courier",, 6,,.F.,,,,,.F.)
	Private oFontCep:= TFont():New("ECTpostnet",,16,,.T.,,,,,.F.)
	Private oFont13 := TFont():New(     "Arial",,10,,.F.,,,,,.F.)
	Private oFont14 := TFont():New(     "Arial",,14,,.F.,,,,,.F.)

	//--- Campos visualizados no MarkBrowse
	aAdd( aCampos, { "E1_OK"		,, "" } )
	aAdd( aCampos, { "E1_FILIAL"	,, "Filial" } )
	aAdd( aCampos, { "E1_PREFIXO"	,, "Prefixo" } )
	aAdd( aCampos, { "E1_NUM"	 	,, "Numero" } )
	aAdd( aCampos, { "E1_PARCELA"	,, "Parcela" } )
	aAdd( aCampos, { "E1_TIPO"		,, "Tipo" } )
	aAdd( aCampos, { "E1_NATUREZ"	,, "Natureza" } )
	aAdd( aCampos, { "E1_CLIENTE"	,, "Cliente" } )
	aAdd( aCampos, { "E1_LOJA"		,, "Loja" } )
	aAdd( aCampos, { "E1_NOMCLI"	,, "Descrição" } )
	aAdd( aCampos, { "E1_VALOR"		,, "Valor" ,PesqPict("SE1", "E1_VALOR"	)} )
	aAdd( aCampos, { "E1_VENCTO"	,, "Vencimento" } )
	aAdd( aCampos, { "E1_VENCREA"	,, "Vencimento Real" } )
	aAdd( aCampos, { "E1_PORTADO"	,, "Banco" } )
	aAdd( aCampos, { "E1_AGEDEP"	,, "Agencia" } )
	aAdd( aCampos, { "E1_CONTA"		,, "Conta" } )
	aAdd( aCampos, { "E1_NUMBCO"	,, "Nosso Numero" } )

	//--- Cria o arquivo temporario
	cNomArqTRB := CriaTrab( aEstrut, .T. )
	dbUseArea( .T.,,cNomArqTRB, cAliasTRB, .F., .F. )

	IndRegua( cAliasTRB, cNomArqTRB,"E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA",,,"Criando Indice, aguarde..." )
	dbClearIndex()
	dbSetIndex( cNomArqTRB + OrdBagExt() )

	//--- Query dos Titulos em Aberto
	_cVctoIni := Dtos(MV_PAR17)
	_cVctoFim := Dtos(MV_PAR18)

	If Select(cAliasTMP) > 0
		(cAliasTMP)->(dbCloseArea())
	Endif

	// Troca do ChangeQuery por BeginSQL em 27/04/17 por Luciano Camargo - TOTVS; ajustado por Kley@TOTVS 23mai17
	BeginSql Alias cAliasTMP
		select * 
		from %table:SE1% SE1
		where SE1.E1_FILIAL = %xFilial:SE1%
		and (SE1.E1_PORTADO = %Exp:MV_PAR01% OR SE1.E1_PORTADO = '')
		and (SE1.E1_AGEDEP  = %Exp:MV_PAR02% OR SE1.E1_AGEDEP = '')
		and (SE1.E1_CONTA   = %Exp:MV_PAR03% OR SE1.E1_CONTA = '')
		and SE1.E1_PREFIXO between %Exp:MV_PAR05% and %Exp:MV_PAR06%
		and SE1.E1_NUM     between %Exp:MV_PAR07% and %Exp:MV_PAR08%
		and SE1.E1_PARCELA between %Exp:MV_PAR09% and %Exp:MV_PAR10%
		and SE1.E1_TIPO    between %Exp:MV_PAR11% and %Exp:MV_PAR12%
		and SE1.E1_CLIENTE between %Exp:MV_PAR13% and %Exp:MV_PAR14%
		and SE1.E1_LOJA    between %Exp:MV_PAR15% and %Exp:MV_PAR16%
		and SE1.E1_NUMBOR  between %Exp:MV_PAR19% and %Exp:MV_PAR20% //Bordero - Solicitacao da FIEB
		and SE1.E1_VENCREA between %Exp:DtoS(MV_PAR17)% and %Exp:_cVctoFim%
		and SE1.E1_SALDO > 0
		and SE1.%notDel%
	EndSQL

	For nCntFor := 1 To Len(aEstrut)
		If ( aEstrut[nCntFor,2]<>"C" )
			TcSetField(cAliasTMP,aEstrut[nCntFor,1],aEstrut[nCntFor,2],aEstrut[nCntFor,3],aEstrut[nCntFor,4])
		EndIf
	Next nCntFor

	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(DbGoTop())

	If !(cAliasTMP)->(Eof())

		dbEval( {|x| nTotRegs++ },,{|| (cAliasTMP)->(!EOF())})
		oProcess:SetRegua1(nTotRegs)
		oProcess:IncRegua1("Iniciando processamento...")
		oProcess:SetRegua2(nTotRegs)
		oProcess:IncRegua2()

		(cAliasTMP)->(dbGotop())

		// Cria TRB a partir do resultado da Query
		While !(cAliasTMP)->(Eof())

			nProcRegs++
			oProcess:IncRegua1("Processando item: "+cValToChar(nProcRegs)+" / "+cValToChar(nTotRegs))
			oProcess:IncRegua2()

			(cAliasTRB)->(DbAppend())
			For nI := 1 To Len(aEstrut)//nTotRegs
				If  (cAliasTRB)->(FieldPos((cAliasTMP)->( FieldName( ni )))) > 0
					(cAliasTRB)->(FieldPut(nI ,;
					(cAliasTMP)->(FieldGet( ;
					(cAliasTMP)->(FieldPos( ;
					(cAliasTRB)->(FieldName( ni ))))))))
				EndIf
			Next
			(cAliasTMP)->(DbSkip())
		EndDo
		(cAliasTMP)->(dbCloseArea())
	Endif

	//--- MarkBrowse
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGotop())

	//--- Monta a Tela com MsSelect e Objetos de Check Box
	DEFINE FONT oFont NAME "Mono AS" SIZE 8,15 BOLD
	DEFINE MSDIALOG oDlg TITLE "Seleção de Títulos em Aberto" From 7,0 To 40,120

	//oMark := MsSelect():New(cAliasTRB,"E1_OK",,aCampos, @lInverte, @cMarca, { 13, 0, 140, 318 } )
	//oMark := MsSelect():New(cAliasTRB,"E1_OK",,aCampos, @lInverte, @cMarca, { 13, 0, 215, 477 } )
	oMark := MsSelect():New(cAliasTRB,"E1_OK",,aCampos, @lInverte, @cMarca, { 30, 0, 215, 477 } )

	oMark:oBrowse:lhasMark := .T.
	oMark:oBrowse:bAllMark := {|| U_SIFR03In( oMark,cAliasTRB ) }  // Na verdade, esse comando esta desabilitado pela instrucao de cima

	//@ 145,010 CHECKBOX oChk VAR lTodos PROMPT "Marca/Desmarca Todos" SIZE 80,7 COLOR CLR_HBLUE OF oDlg PIXEL ON CLICK U_SIFR03In( oMark,cAliasTRB ); lTodos := .F.; oChk:oFont := oDlg:oFont
	//@ 145,110 CHECKBOX oInv VAR lChang PROMPT "Inverte Seleção" SIZE 80,7 COLOR CLR_HBLUE OF oDlg PIXEL ON CLICK U_SIFR03Cg( oMark,cAliasTRB ); lChang := .F.; oChk:oFont := oDlg:oFont
	@ 222,010 CHECKBOX oChk VAR lTodos PROMPT "Marca/Desmarca Todos" SIZE 80,7 COLOR CLR_HBLUE OF oDlg PIXEL ON CLICK U_SIFR03In( oMark,cAliasTRB ); lTodos := .F.; oChk:oFont := oDlg:oFont
	@ 222,110 CHECKBOX oInv VAR lChang PROMPT "Inverte Seleção"      SIZE 80,7 COLOR CLR_HBLUE OF oDlg PIXEL ON CLICK U_SIFR03Cg( oMark,cAliasTRB ); lChang := .F.; oChk:oFont := oDlg:oFont

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {||( nOpc := 1, oDlg:End() )}, {||(nOpc := 0, oDlg:End())},,) CENTERED

	DeleteObject( oMark )
	DeleteObject( oDlg )
	DeleteObject( oChk )
	DeleteObject( oInv )

	If nOpc == 1

		lRet := xGeraBol(cAliasTRB)

		if lRet
			DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE "Impressão" OF oDlg PIXEL
			@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL

			@ 015,017 SAY "Esta rotina tem por objetivo imprimir" OF oDlg PIXEL Size 150,010  COLOR CLR_HBLUE
			@ 030,017 SAY "boletos bancários.                   " OF oDlg PIXEL Size 150,010  COLOR CLR_HBLUE
			@ 045,017 SAY "" OF oDlg PIXEL Size 150,010 COLOR CLR_HBLUE

			@  6,167 BUTTON "&Imprime" SIZE 036,012 ACTION oPrn:Print()   OF oDlg PIXEL
			@ 28,167 BUTTON "&Setup"   SIZE 036,012 ACTION oPrn:Setup()   OF oDlg PIXEL
			@ 49,167 BUTTON "Pre&view" SIZE 036,012 ACTION oPrn:Preview() OF oDlg PIXEL
			@ 70,167 BUTTON "Sai&r"    SIZE 036,012 ACTION oDlg:End()     OF oDlg PIXEL

			ACTIVATE MSDIALOG oDlg CENTERED
		endif   

	Endif

	If Select(cAliasTRB) != 0
		dbSelectArea(cAliasTRB)
		dbCloseArea()
		FErase(cNomArqTrb+GetDBExtension())
		FErase(cNomArqTrb+OrdBagExt())
	Endif

Return

/*/{Protheus.doc} xGeraBol
//Função STATIC Geração do Boleto

@author 	Carlos Queiroz e Felipe Queiroz
@since 		19/06/13
@version 	P11.8
@param 		cAliasTRB, characters, descricao
@obs 		Melhorias 27/04/2017 por Luciano Camargo - TOTVS
@type 		function

/*/

Static Function xGeraBol(cAliasTRB)

	Local cStartPath 	:= GetSrvProfString("StartPath","")
	Local cBmp 			:= ""
	Local nLin 			:= 0
	Local nLinMsg		:= 0
	Local cCodCep 		:= ""
	Local cCodBarras 	:= ""
	Local cCCedente		:= ""
	Local cCodCliente	:= ""		// Uso exclusivo do Banco SICOOB
	Local cConvenio 	:= ""
	Local aObserv		:= {}
	Local nTamMem		:= 12

	//Local nTotRegTRB	:= 0		// teste kley

	// Variáveis para 'Código de Barras' e 'Linha Digitável'
	Local cBanco		:= ""
	Local cMoeda		:= ""
	Local cFtVencto		:= ""
	Local cValor      	:= ""
	Local cCodBenef		:= ""
	Local cDVBenef 		:= ""
	Local cNNSeq1		:= ""
	Local cNNConst1		:= ""
	Local cNNSeq2		:= ""
	Local cNNConst2		:= ""
	Local cNNSeq3		:= ""
	Local cDVCpoLv		:= ""
	Local cDVGERAL		:= ""

	// Variáveis para 'Linha Digitável' apenas
	Local cCpoLv0105	:= ""
	Local cDVCpo1LD		:= ""
	Local cCpoLv0615	:= ""
	Local cDVCpo2LD		:= ""
	Local cCpoLv1625	:= ""
	Local cDVCpo3LD		:= ""
	Local cLinhaDig		:= ""

	Local cDigNnum 		:= ""
	Local cNossoNum 	:= ""

	Local cCartCob		:= ""		// Uso Banco SICOOB - FIEMG
	Local cAgencia		:= ""		// Uso Banco SICOOB - FIEMG
	Local cModalid		:= ""		// Uso Banco SICOOB - FIEMG
	Local cParcela		:= ""		// Uso Banco SICOOB - FIEMG

	Local cLinDgCpo1	:= ""		// Campo Linha Digitável - Uso Banco SICOOB - FIEMG
	Local cLinDgCpo2	:= ""		// Campo Linha Digitável - Uso Banco SICOOB - FIEMG
	Local cLinDgCpo3	:= ""		// Campo Linha Digitável - Uso Banco SICOOB - FIEMG
	Local cLinDgCpo4	:= ""		// Campo Linha Digitável - Uso Banco SICOOB - FIEMG
	Local cLinDgCpo5	:= ""		// Campo Linha Digitável - Uso Banco SICOOB - FIEMG

	Local aCB_RN_NN		:= {}
	Local nVlrAbat		:= 0

	/*
	cBMP  := cStartPath+"BOL_"+cEmpAnt+cFilAnt+".bmp"
	If !File(cBMP)
	cBMP := cStartPath+"BOL_"+cEmpAnt+".bmp"
	Endif
	*/
	cBMP  := cStartPath+"BOLETO.jpg"

	(cAliasTRB)->(dbGoTop())

	oPrn := TMSPrinter():New("Boleto Bancário")
	oPrn:SetPortrait() // ou SetLandscape()

	While !(cAliasTRB)->(EOF())

		//dbEval( {|x| nTotRegTRB++ },,{|| (cAliasTRB)->(!EOF())})
		//MsgInfo("Total de Regs TRB: " + cValtoChar(nTotRegTRB))

		If (cAliasTRB)->E1_OK # cMarca
			(cAliasTRB)->(dbSkip())
			Loop
		EndIf

		//dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+(cAliasTRB)->(E1_CLIENTE+E1_LOJA)))  .Or. Empty((cAliasTRB)->(E1_CLIENTE+E1_LOJA))
		If ! SA1->(Found())
			MsgStop("Cliente nao localizado:" + CRLF+CRLF + ;
			"Cliente / Loja : " + (cAliasTRB)->E1_CLIENTE+" / "+(cAliasTRB)->E1_LOJA ,"Atenção")
			(cAliasTRB)->(dbSkip())
			Loop
		Endif

		//	Begin Transaction

		/* Posicionamento nos registros das tabelas a serem usadas ******************/

		//dbSelectArea("SE1")
		SE1->(dbSetOrder(1))
		SE1->(dbSeek((cAliasTRB)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))

		//dbSelectArea("SA6")
		SA6->(dbSetOrder(1))
		SA6->(dbSeek(xFilial("SA6")+(cAliasTRB)->(E1_PORTADO+E1_AGEDEP+E1_CONTA)))

		//dbSelectArea("SEE")
		SEE->(dbSetOrder(1))
		SEE->(dbSeek(xFilial("SEE")+(cAliasTRB)->(E1_PORTADO+E1_AGEDEP+E1_CONTA+mv_par04)))

		SC5->(dbsetorder(1))
		SC5->(dbSeek(xFilial("SC5")+(cAliasTRB)->E1_PEDIDO))

		/* Validações ***************************************************************/

		If Empty(SE1->E1_PORTADO)                                                         
			//Caso seja utilizado o nosso numero enviado na integração, o banco de impressão deve ser o mesmo banco enviado pela integração
			If !Empty(SC5->C5_BANCO) .And. Alltrim(mv_par01) <> Alltrim(SC5->C5_BANCO)
				MsgStop("O Banco informado no Pedido de vendas "+ SC5->C5_NUM + "é diferente o banco selecionado.")
				If Select(cAliasTRB) != 0
					dbSelectArea(cAliasTRB)
					dbCloseArea()
					FErase(cNomArqTrb+GetDBExtension())
					FErase(cNomArqTrb+OrdBagExt())
				Endif
				//	DisarmTransaction()	
				Return .F.
			Endif	
			RecLock("SE1",.F.)
			SE1->E1_PORTADO := MV_PAR01
			SE1->E1_AGEDEP	:= MV_PAR02
			SE1->E1_CONTA	:= MV_PAR03                         
			MsUnLock() 					
			SEE->(dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA+mv_par04)))
		Endif

		If ! SEE->(Found())
			MsgStop("Parâmetros de Bancos (SEE) não cadastrado para o banco do título abaixo:" + CRLF+CRLF + ;
			"Filial/Prefixo/Número/Parcela/Tipo: " + SE1->E1_FILIAL+" / "+SE1->E1_PREFIXO+" / "+SE1->E1_NUM+" / "+SE1->E1_PARCELA+" / "+SE1->E1_TIPO + CRLF+CRLF+ ;
			"Banco/Agência/Conta/SubConta: " + SE1->E1_PORTADO + " / " + SE1->E1_AGEDEP + " / " + SE1->E1_CONTA + " / " + mv_par04 ,"Atenção")
			lRet := .F.
			//Break
			//DisarmTransaction()	
			Return .F.
		Endif

		/* Tratamentos para 'Código Cedente' ****************************************/
		Do Case
			Case cCodBanco =="104"

			If !Empty(SEE->EE_XNCEDEN)
				cCCedente := Alltrim(SEE->EE_XNCEDEN)
			Else
				//	cCCedente := Alltrim(SE1->E1_AGEDEP) + Iif(!Empty(SA6->A6_DVAGE),"-","") + Alltrim(SA6->A6_DVAGE) + "/" + ;
				//				 Alltrim(SEE->EE_CODEMP) + "-" + Modulo11(Alltrim(SEE->EE_CODEMP)) 
				//Ajustado para atender a FIEB formato AAAA / XXXXXX-D						 
				cCCedente := Alltrim(SE1->E1_AGEDEP) + "/" + ;
				Alltrim(SEE->EE_CODEMP) + "-" + Modulo11(Alltrim(SEE->EE_CODEMP))
			EndIf				

			Case cCodBanco =="756"

			//---< ATENÇÃO! Não mover as variáveis abaixo da ordem em que se encontram >----
			cCodBenef	:= PadL( Right(StrTran(StrTran(AllTrim(SEE->EE_CODEMP),"-",""),".",""),7) ,7,"0")	// 7 posições

			/* Inf. para Nosso Número */
			cCodCliente	:= PadL( cCodBenef, 10, "0")			// Para uso no Nosso Número - 10 posições

			/* Inf. para Código de Barras e Nosso Número */
			cDVBenef 	:= Right(cCodBenef, 1)					// Para uso no Código de Barras
			cCodBenef	:= Left( cCodBenef, 6)					// Para uso no Código de Barras

			/* Inf. para campo AGÊNCIA / CÓDIGO DO BENECIÁRIO */
			cAgencia	:= PadL(AllTrim(SE1->E1_AGEDEP),4,"0")	// Inf. para Impress. do Boleto
			cCCedente 	:= cAgencia + "/" + cCodBenef + "-" + cDVBenef

			Otherwise
			cCCedente := Alltrim(SE1->E1_AGEDEP) + Iif(!Empty(SA6->A6_DVAGE),"-","") + Alltrim(SA6->A6_DVAGE) + "/" + ;
			Alltrim(SE1->E1_CONTA)  + Iif(!Empty(SA6->A6_DVCTA),"-","") + Alltrim(SA6->A6_DVCTA) 
		EndCase

		/* Tratamentos para 'Nosso Número' ******************************************/
		If Empty(SE1->E1_NUMBCO) .And. Empty(SE1->E1_XIDCNAB)
			If SEE->(Found())
				NossoNum()			// Trata Nosso Numero, corresp. ao campo EE_FAXATU, e atualiza E1_NUMBCO
			Endif

			Do Case

				Case cCodBanco == '041'		// Digito Duplo para o Banrisul
				cNossoNum := Substr(SE1->E1_NUMBCO,1,8)
				cDigNNum  := U_Modulo10(cNossoNum)
				cDigNNum  += DigMod11(Alltrim(cNossoNum)+cDigNNum,20,70)

				Case cCodBanco == '001' 	// Banco do Brasil						
				If  Len(Alltrim(SEE->EE_CODEMP)) < 7
					If Alltrim(SEE->EE_XCART) $ "16|18" .and.  Len(Alltrim(SEE->EE_CODEMP))== 6 .And. !Empty(SEE->EE_xNOSNUM)

						// inserido por carlos queiroz e felipe queiroz em 19/06/13
						if (Val(Alltrim(Substr(SE1->E1_NUMBCO,2,11)))+1) > Val(SEE->EE_FAXFIM)
							msgstop("O número a ser atualizado de Faixa Atual (cadastro de Parâmentros de Bancos) ultrapassa o limite estabelecido do campo Faixa Fim."+chr(13)+chr(10)+"Efetue o cadastro de um novo convênio e atualize o cadastro de Parâmetros de Banco.","Boleto não gerado")
							//DisarmTransaction()	
							Return .F.
						endif 

						RecLock("SEE",.F.)            
						SEE->EE_FAXATU := Str(Val(Alltrim(Substr(SE1->E1_NUMBCO,2,11)))+1,11)
						MsUnLock()                                                  

						cNossoNum := Alltrim(SEE->EE_xNOSNUM)+Substr(SE1->E1_NUMBCO,2,11)    
					Else
						cNossoNum := StrZero(Val(SE1->E1_NUMBCO),11)     //O Nosso Numero para o Banco do Brasil possui 11 posicoes.

						RecLock("SE1",.F.)
						Replace SE1->E1_NUMBCO With cNossoNum
						SE1->( MsUnlock( ) )
						If Len(cnossonum) <> Len(SEE->EE_FAXATU)                    

							// inserido por carlos queiroz e felipe queiroz em 19/06/13
							if (Val(Alltrim(Substr(SE1->E1_NUMBCO,2,11)))+1) > Val(SEE->EE_FAXFIM)
								msgstop("O número a ser atualizado de Faixa Atual (cadastro de Parâmentros de Bancos) ultrapassa o limite estabelecido do campo Faixa Fim."+chr(13)+chr(10)+"Efetue o cadastro de um novo convênio e atualize o cadastro de Parâmetros de Banco.","Boleto não gerado")
								//				DisarmTransaction()	
								Return .F.	
							endif 

							RecLock("SEE",.F.)            
							SEE->EE_FAXATU := Str(Val(Alltrim(cNossoNum))+1,Len(cNossoNUM)  )
							MsUnLock()                                                  
						Endif		

					Endif

				ElseIf	Len(Alltrim(SEE->EE_CODEMP))== 7

					// inserido por carlos queiroz e felipe queiroz em 19/06/13
					If (Val(Alltrim(Substr(SE1->E1_NUMBCO,2,11)))+1) > Val(SEE->EE_FAXFIM)
						msgstop("O número a ser atualizado de Faixa Atual (cadastro de Parâmentros de Bancos) ultrapassa o limite estabelecido do campo Faixa Fim."+chr(13)+chr(10)+"Efetue o cadastro de um novo convênio e atualize o cadastro de Parâmetros de Banco.","Boleto não gerado")
						//		DisarmTransaction()	
						Return .F.
					endif 

					cNossoNum:= SubsTr(SE1->E1_NUMBCO,3,10)		// o mesmo que 10 posições do EE_FAXATU     

					RecLock("SEE",.F.)            
					SEE->EE_FAXATU := StrZero(Val(Alltrim(cNossoNum))+1,10)
					SEE->(MsUnLock())

				Else   
					//cNossoNum := Substr(SE1->E1_NUMBCO,1,17)
					If !Empty(SEE->EE_xNOSNUM)
						cNossoNum := Alltrim(SEE->EE_xNOSNUM)+Substr(SE1->E1_NUMBCO,1,11)
					Endif	
				Endif			
				//cDigNNum := DigMod11(cNossoNum,20,90)

				Case cCodBanco == '033'		// Santander
				cNossoNum := Substr(SE1->E1_NUMBCO,1,12)
				cDigNNum  := DigMod11(cNossoNum,20,90)

				Case cCodBanco == '341' 	// Itau
				cNossoNum := Substr(SE1->E1_NUMBCO,1,8)
				cDigNNum  := U_Modulo10(Alltrim(SE1->E1_AGEDEP)+Alltrim(SE1->E1_CONTA)+Alltrim(SEE->EE_XCART)+Alltrim(cNossoNum))

				Case cCodBanco == '104' 	// CEF            
				cNossoNum := "14000"	// fixo
				cNossoNum += NossoNum()	// Nosso Núm. c/ 12 dígitos
				//cNossoNum := Substr(SEE->EE_CODEMP,1,6) + Substr(SE1->E1_NUMBCO,4,9) 	//Alterado por F.Lagatta conforme solicitacao da Valeria em 15/01
				//cDigNNum := DigMod11(Alltrim(SEE->EE_XCART)+StrZero(Val(NossoNum()),15),20,90)
				//cDigNNum := DigMod11(cNossoNum,20,90)			// Alterado por F.Lagatta conforme solicitacao da Valeria em 15/01
				cDigNNum  := Modulo11(cNossoNum)

				Case cCodBanco == '756' 	// SICOOB
				cNossoNum := PadL(Substr(AllTrim(SE1->E1_NUMBCO), Len(AllTrim(SE1->E1_NUMBCO))-7 +1, 7),7,"0")	// Tamanho máximo do Nosso Número: 7
				//cDigNNum  := Mod11Sic( PadL(Alltrim(SE1->E1_AGEDEP),4,"0") + PadL(Alltrim(SE1->E1_CONTA),10,"0") + cNossoNum )	// Núm. Cooperativa (4) + Código do Cliente (10) + Nosso Núm. (7)
				cDigNNum  := Mod11Sic( cAgencia + cCodCliente + cNossoNum )	// Núm. Cooperativa (4) + Código do Cliente (10) + Nosso Núm. (7)

				Otherwise
				cNossoNum := SE1->E1_NUMBCO  
				cDigNNum  := U_Modulo10(cNossoNum)

			EndCase

			// Atualiza Nosso Numero com Digito
			RecLock("SE1",.F.)            
			If Len(Alltrim(SE1->E1_NUMBCO)) > 12 .and. cCodBanco <> '104' // CEF 
				SE1->E1_NUMBCO  := Substr(Alltrim(cNossoNum),7,11) + Alltrim(cDigNNum)			
			Else
				SE1->E1_NUMBCO  := Alltrim(cNossoNum) + Alltrim(cDigNNum)
			Endif
			SE1->E1_xNUMBCO := Alltrim(cNossoNum) + Alltrim(cDigNNum)			
			SE1->(MsUnLock())

		Else  // Se E1_NUMBCO ou E1_XIDCNAB for diferente de vazio; o boleto já foi impresso e o 'Nosso Número' já foi gerado

			If !Empty(SE1->E1_XIDCNAB) .And. Empty(SE1->E1_NUMBCO) 	// veio do legado
				cNossoNum := Alltrim(SE1->E1_XIDCNAB)
				cDigNNum  := Right(Alltrim(SE1->E1_XIDCNAB),1)
				RecLock("SE1",.F.)            
				SE1->E1_NUMBCO := cNossoNum
				MsUnLock()
			Else                                          
				cNossoNum := Left(AllTrim(SE1->E1_NUMBCO),Len(Alltrim(SE1->E1_NUMBCO))-1) 		//Retira o digito verificador
				If !Empty(Alltrim(SEE->EE_xNOSNUM))
					cNossoNum := Alltrim(SEE->EE_xNOSNUM) + cNossonum
				Endif
				cDigNNum  := Alltrim(Substr(SE1->E1_NUMBCO,Len(Alltrim(SE1->E1_NUMBCO)), Len(Alltrim(SE1->E1_NUMBCO))))
				cDigNNum  := Right(Alltrim(SE1->E1_NUMBCO),1)

			Endif	
		Endif	

		If Len(Alltrim(SEE->EE_CODEMP)) == 7 	// Banco do Brasil
			If Empty(SE1->E1_XIDCNAB)
				//Salva o nosso numero impresso no xidcnab para a baixa via arquivo de retorno CNAB
				RecLock("SE1",.F.)
				Replace SE1->E1_xIDCNAB With Alltrim(SEE->EE_CODEMP)+ Alltrim(cNossoNum) //Ajustado conforme e-mail de 01/fev.
				If SubStr(SE1->E1_FILIAL,3,2) == "CE" /*Ajustdo conforme necessidade da FIEC*/
					Replace SE1->E1_NUMBCO  With Alltrim(SEE->EE_CODEMP)+ Alltrim(cNossoNum) 
				EndIf
				SE1->(MsUnlock())
			EndIf
			
			if cCodBanco == "001" /*By Aleluia 070818*/
				Reclock("SE1", .F.)
				SE1->E1_NUMBCO := Alltrim(SEE->EE_CODEMP)+ Alltrim(RIGHT(SEE->EE_FAXATU,10))
				SE1->E1_XIDCNAB := SE1->E1_NUMBCO
				SE1->(MsUnlock())
			endif

			cNossoNum := SE1->E1_XIDCNAB
		Endif	

		//End Transaction 

		/* Tratamentos para 'Linha Digitável e Código de Barras' ************************/
		Do Case

			Case cCodBanco == "104"

			/*---------------------------------------------------------------------------------------------------\
			/                                  C Ó D I D O   D E   B A R R A S                                     \
			+-------------+--------------------------------------------------------------------------------+---------+
			| Exemplo	  |  Descrição																	   | Posição |
			+-------------+--------------------------------------------------------------------------------+---------+
			| 104		  |  Banco (Fixo)																   |  01-03  |
			| 9			  |  Moeda (Fixo)																   |  04-04  |
			+-------------+--------------------------------------------------------------------------------+---------+
			| 9			  |  Dígito Verificador GERAL             										   |  05-05  |
			+-------------+--------------------------------------------------------------------------------+---------+
			| 9999        |  Fator de Vencimento (número de dias a partir da data base 07/10/1997)		   |  06-09  |
			| 9999999999  |  Valor (valor sendo 2 últimos dígitos para centavos e zeros a esquerda) 	   |  10-19  |
			| 539337	  |  Código do Beneficiário  													   |  20-25  |
			| 0			  |  DV do Código do Beneficiário 												   |  26-26  |
			| 999		  |  Nosso Número – Seqüência 1 (3ª a 5ª posição do Nosso Número)				   |  27-29  |
			| 1			  |  Constante 1 – Modalidade/Carteira Cobrança (1ª posição do Nosso Número) 	   |  30-30  |
			| 999		  |  Nosso Número – Seqüência 2 (6ª a 8ª posição do Nosso Número) 				   |  31-33  |
			| 4			  |  Constante 2 – Identificador de Emissão do boleto (2ª posição do Nosso Número) |  34-34  |
			| 999999999	  |  Nosso Número – Seqüência 3 (9ª a 17ª posição do Nosso Número) 				   |  35-43  |
			| 9			  |  DV do Campo Livre 															   |  44-44  |
			+-------------+--------------------------------------------------------------------------------+--------*/

			/*------------------------------------------------------------------------------------------------------------------------\
			/                                   		    L I N H A   D I G I T Á V E L                                                \
			+------------------------------+--------------------------+--------------------------+---------+------------------------------+
			|	       C A M P O   1       |	    C A M P O   2	  |		  C A M P O   3		 | CAMPO 4 |		 C A M P O   5        |
			+------------------------------+--------------------------+--------------------------+---------+------------------------------+
			| Banco  Moeda	CL 1-5 		DV | CL 6-15 			   DV | CL 16-25 			  DV | 	DVG	   | FV 	  VALOR               |
			| 1 2 3  4 		5 . 6 7 8 9  0 | 1 2 3 4 5 . 6 7 8 9 0  1 | 2 3 4 5 6 . 7 8 9 0 1  2 |	 3 	   | 4 5 6 7  8 9 0 1 2 3 4 5 6 7 |
			+------------------------------+--------------------------+--------------------------+---------+------------------------------+
			| CL -> Campo Livre  /  DV -> Dígito Verificador  /  DVG -> Dígito Verificador Geral										  |
			+-------------+--------------------------------------------------------------------------------+---------+--------------------+
			| Exemplo	  |  Descrição																	   | Posição |                   /
			+-------------+--------------------------------------------------------------------------------+---------+                  /
			| 104		  |  Banco (Fixo)																   |  01-03  |                 /
			| 9			  |  Moeda (Fixo)																   |  04-04  |                /
			| 53933		  |  Código do Beneficiário (1ª a 5ª posição)									   |  05-09  |               / 
			| 9			  |  Dígito Verificador do CAMPO 1 												   |  10-10  |              /
			+-------------+--------------------------------------------------------------------------------+---------+             /
			| 7			  |  Código do Beneficiário (6ª posição)										   |  11-11  |            /
			| 0			  |  DV do Código do Beneficiário 												   |  12-12  |           / 
			| 999		  |  Nosso Número – Seqüência 1 (3ª a 5ª posição do Nosso Número)				   |  13-15  |          /
			| 1			  |  Constante 1 – Modalidade/Carteira Cobrança (1ª posição do Nosso Número) 	   |  16-16  |         /
			| 999		  |  Nosso Número – Seqüência 2 (6ª a 8ª posição do Nosso Número) 				   |  17-19  |        /
			| 4			  |  Constante 2 – Identificador de Emissão do boleto (2ª posição do Nosso Número) |  20-20  |       /
			| 9			  |  Dígito Verificador do CAMPO 2 												   |  21-21  |      /
			+-------------+--------------------------------------------------------------------------------+---------+     /
			| 999999999	  |  Nosso Número – Seqüência 3 (9ª a 17ª posição do Nosso Número) 				   |  22-30  |    /
			| 9			  |  DV do Campo Livre 															   |  31-31  |   /
			| 9			  |  Dígito Verificador do CAMPO 3 												   |  32-32  |  /
			+-------------+--------------------------------------------------------------------------------+---------+ /
			| 9			  |  Dígito Verificador GERAL - CAMPO 4 										   |  33-33  |/
			+-------------+--------------------------------------------------------------------------------+---------+
			| 9999        |  Fator de Vencimento (número de dias a partir da data base 07/10/1997)		   |  34-37  |
			| 9999999999  |  Valor (valor sendo 2 últimos dígitos para centavos e zeros a esquerda) 	   |  38-47  |
			+-------------+--------------------------------------------------------------------------------+--------*/

			/* Variáveis para 'Código de Barras' e 'Linha Digitável' **********/
			cBanco		:= "104"
			cMoeda		:= "9"
			cFtVencto	:= cValtoChar(DateDiffDay(CtoD("07/10/97"), SE1->E1_VENCTO))
			cValor      := StrZero( (Round(SE1->E1_VALOR +SE1->E1_SDACRES -SE1->E1_SDDECRE -SE1->E1_DESCONT ;
			-SE1->E1_INSS -SE1->E1_VALLIQ, 2)*100) ,10)
			cCodBenef	:= Alltrim(SEE->EE_CODEMP)
			cDVBenef 	:= Modulo11(Alltrim(SEE->EE_CODEMP))
			cNNSeq1		:= Substring(cNossoNum,3,3)
			cNNConst1	:= Substring(cNossoNum,1,1)
			cNNSeq2		:= Substring(cNossoNum,6,3)
			cNNConst2	:= Substring(cNossoNum,2,1)
			cNNSeq3		:= Substring(cNossoNum,9,9)
			//			cDVCpoLv	:= Modulo11(cNNSeq1+cNNConst1+cNNSeq2+cNNConst2+cNNSeq3) 
			cDVCpoLv	:= Modulo11(cCodBenef+cDVBenef+cNNSeq1+cNNConst1+cNNSeq2+cNNConst2+cNNSeq3)

			cDVGERAL	:= Modulo11(cBanco+cMoeda+cFtVencto+cValor+cCodBenef+cDVBenef+cNNSeq1+cNNConst1+cNNSeq2+cNNConst2+cNNSeq3+cDVCpoLv)

			/* Formatação do 'Código de Barras' *******************************/
			cCodBarras	:= cBanco  + cMoeda    + cDVGERAL + cFtVencto + cValor  + cCodBenef + cDVBenef + ;
			cNNSeq1 + cNNConst1 + cNNSeq2  + cNNConst2 + cNNSeq3 + cDVCpoLv


			/* Variáveis para 'Linha Digitável' apenas ************************/
			cCpoLv0105	:= Substring(cCodBenef,1,5)
			cDVCpo1LD	:= U_Modulo10(cBanco+cMoeda+cCpoLv0105)

			cCpoLv0615	:= Substring(cCodBenef,6,1) + cDVBenef + cNNSeq1 + cNNConst1 + cNNSeq2 + cNNConst2
			cDVCpo2LD	:= U_Modulo10(cCpoLv0615)

			cCpoLv1625	:= cNNSeq3 + cDVCpoLv
			cDVCpo3LD	:= U_Modulo10(cCpoLv1625)

			/* Formatação da 'Linha Digitável' ********************************/
			cLinhaDig	:= cBanco + cMoeda + Substring(cCpoLv0105,1,1)
			cLinhaDig	+= "."
			cLinhaDig	+= Substring(cCpoLv0105,2,5) + cDVCpo1LD
			cLinhaDig	+= Space(1)

			cLinhaDig	+= Substring(cCpoLv0615,1,5)
			cLinhaDig	+= "."
			cLinhaDig	+= Substring(cCpoLv0615,6,5) + cDVCpo2LD
			cLinhaDig	+= Space(1)

			cLinhaDig	+= Substring(cCpoLv1625,1,5)
			cLinhaDig	+= "."
			cLinhaDig	+= Substring(cCpoLv1625,6,5) + cDVCpo3LD
			cLinhaDig	+= Space(1)

			cLinhaDig	+= cDVGERAL
			cLinhaDig	+= Space(1)

			cLinhaDig	+= cFtVencto + cValor

			Case cCodBanco == "756"

			/*---------------------------------------------------------------------------------------------------\
			/                                  C Ó D I D O   D E   B A R R A S                                     \
			+-------------+--------------------------------------------------------------------------------+---------+
			| Exemplo	  |  Descrição																	   | Posição |
			+-------------+--------------------------------------------------------------------------------+---------+
			| 756		  |  Banco (Fixo)																   |  01-03  |
			| 9			  |  Moeda (Fixo)																   |  04-04  |
			+-------------+--------------------------------------------------------------------------------+---------+
			| 9			  |  Dígito Verificador GERAL - Modulo 11  										   |  05-05  |
			+-------------+--------------------------------------------------------------------------------+---------+
			| 9999        |  Fator de Vencimento (número de dias a partir da data base 07/10/1997)		   |  06-09  |
			| 9999999999  |  Valor (valor sendo 2 últimos dígitos para centavos e zeros a esquerda) 	   |  10-19  |
			+-------------+----------------------- C A M P O   L I V R E ----------------------------------+---------+
			| 1     	  |  Código da Carteira de Cobrança												   |  20-20  |
			| 3330  	  |  Código da agência/cooperativa - "3330" (E1_AGEDEP)							   |  21-24  |
			| 01		  |  Código da modalidade - "01" - Simples Com Registro							   |  25-26  |
			| 0001465	  |  Código do beneficiário/cliente - "0001465" - Cliente-DV (E1_CONTA)			   |  27-33  |
			| 99999999	  |  Nosso número do boleto c/DV - 8 posições 	   								   |  34-41  |
			| 001		  |  Número da parcela a que o boleto se refere - "001" se parcela única		   |  42-44  |
			+-------------+--------------------------------------------------------------------------------+--------*/

			/*-----------------------------------------------------------------\
			/             		    L I N H A   D I G I T Á V E L                 \
			/*------------+--------------+--------------+---------+----------------+
			|   Campo 1   |	  Campo 2    |   Campo 3	| Campo 4 |	   Campo 5	   |\		
			+-------------+--------------+--------------+---------+----------------+ \
			| AAABC.DDDDE | FFGGG.GGGGHI | HHHHH.HHJJJK | L       | MMMMNNNNNNNNNN |  \				
			+-------------+--------------+--------------+---------+----------------+---+------------+
			| A =	Código do Sicoob na câmara de compensação - "756"								|
			| B =	Código da moeda - "9"															|
			| C =	Código da carteira - "1" - Simples Com Registro 							    |
			| D =	Código da agência/cooperativa - "3330" (E1_AGEDEP)								|
			| E =	Dígito verificador do Campo 1 - Modulo 10 										|
			| F =	Código da modalidade - "01" - Simples Com Registro 							    |
			| G =	Código do beneficiário/cliente - "0001465" - Cliente-DV (E1_CONTA)				|
			| H =	Nosso número do boleto c/DV - 8 posições										|
			| I =	Dígito verificador do Campo 2 - Modulo 10										|
			| J =	Número da parcela a que o boleto se refere - "001" se parcela única				|				
			| K =	Dígito verificador do Campo 3 - Modulo 10										|
			| L =	Dígito verificador do Código de Barras - Modulo 11 aplicado ao Cód. Barras		|
			| M =	Fator de vencimento																|
			| N =	Valor do boleto - Em casos de cobrança com valor em aberto (o valor a ser pago é|
			|		preenchido pelo próprio pagador) ou cobrança em moeda variável, deve ser 		|
			|		preenchido com zeros															|
			+---------------------------------------------------------------------------------------*/	

			/* Variáveis para 'Código de Barras' e 'Linha Digitável' - Padrão **********/
			cBanco		:= cCodBanco
			cMoeda		:= "9"
			cFtVencto	:= cValtoChar(DateDiffDay(CtoD("07/10/97"), SE1->E1_VENCTO))
			cValor      := StrZero( (Round(SE1->E1_VALOR +SE1->E1_SDACRES -SE1->E1_SDDECRE -SE1->E1_DESCONT ;
			-SE1->E1_INSS -SE1->E1_VALLIQ, 2)*100) ,10)

			/* Variáveis para 'Código de Barras' e 'Linha Digitável' - Campo Livre *****/
			cCartCob	:= PadL(SubStr(SEE->EE_XCART,3,1),1,"0")								// Alinha texto à direita e acrescenta zeros à esquerda
			//cAgencia	:= PadL(AllTrim(SE1->E1_AGEDEP),4,"0")									// Definido em 'Código Cedente'
			cModalid	:= PadL(SubStr(SEE->EE_XCART,5,2),2,"0")
			// cCodBenef, cDVBenef, cNossoNum e cDigNNum - Definidos acima
			//cCodBenef	:= PadL(StrTran(StrTran(AllTrim(SEE->EE_CONTA),"-",""),".",""),6,"0")	// Remove espaços, traços e pontos, e alinha texto à direita e acrescenta zeros à esquerda
			//cCodBenef	:= PadL(StrTran(StrTran(Right(AllTrim(SEE->EE_CONTA),6),"-",""),".",""),6,"0")	// Remove espaços, traços e pontos, e alinha texto à direita e acrescenta zeros à esquerda
			//cDVBenef 	:= PadL(AllTrim(SEE->EE_DVCTA),1,"0")
			//cNossoNum
			//cDigNNum
			cParcela	:= Iif(Empty(SE1->E1_PARCELA), "001", PadL(AllTrim(SE1->E1_PARCELA),3,"0"))

			cDVGERAL	:= Modulo11(cBanco+cMoeda+cFtVencto+cValor+cCartCob+cAgencia+cModalid+cCodBenef+cDVBenef+cNossoNum+cDigNNum+cParcela)

			/* Formatação do 'Código de Barras' *******************************/
			cCodBarras	:= cBanco  + cMoeda    + cDVGERAL + cFtVencto + cValor  + ;
			cCartCob + cAgencia + cModalid + cCodBenef + cDVBenef + cNossoNum + cDigNNum + cParcela

			/* Formatação da 'Linha Digitável' ********************************/
			cLinDgCpo1	:= cBanco + cMoeda + cCartCob
			cLinDgCpo1	+= "."
			cLinDgCpo1	+= cAgencia
			cLinDgCpo1	+= U_Modulo10( StrTran(cLinDgCpo1,".","") )
			cLinDgCpo1	+= Space(1)

			cLinDgCpo2	:= cModalid + SubsTr(cCodBenef,1,3)
			cLinDgCpo2	+= "."
			cLinDgCpo2	+= SubsTr(cCodBenef,4,3) + cDVBenef + SubsTr(cNossoNum,1,1)
			cLinDgCpo2	+= U_Modulo10( StrTran(cLinDgCpo2,".","") )
			cLinDgCpo2	+= Space(1)

			cLinDgCpo3	:= SubsTr(cNossoNum,2,5)
			cLinDgCpo3	+= "."
			cLinDgCpo3	+= SubsTr(cNossoNum,7,2) + cDigNNum + cParcela
			cLinDgCpo3	+= U_Modulo10( StrTran(cLinDgCpo3,".","") )
			cLinDgCpo3	+= Space(1)

			cLinDgCpo4	:= cDVGERAL
			cLinDgCpo4	+= Space(1)

			cLinDgCpo5	:= cFtVencto + cValor

			cLinhaDig	:= cLinDgCpo1 + cLinDgCpo2 + cLinDgCpo3 + cLinDgCpo4 + cLinDgCpo5

			Case cCodBanco == "001"		// Aleluia 070818

			cBanco		:= cCodBanco
			cMoeda		:= "9"
			nVlrAbat 	:= SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1 ,, SE1->E1_CLIENTE, SE1->E1_LOJA)

			aCB_RN_NN := Ret_cBarra(cBanco+cMoeda,;// [1] Banco+Moeda
			SUBSTR(SA6->A6_AGENCIA, 1, 4),;// [2] Agência
			Alltrim(SA6->A6_NUMCON),;// [3] Conta
			SA6->A6_DVCTA,;// [4] Dígito da Conta
			ALLTRIM(SUBS(SEE->EE_CODEMP,1,7) + StrZero(Val(SEE->EE_FAXATU), 10)),;// [5] Nosso Número
			SE1->E1_VALOR - nVlrAbat,;// [6] Valor do Título
			SE1->E1_VENCTO;// [7] Vencimento
			)

			if len(aCB_RN_NN) > 0
				/* Formatação do 'Código de Barras' *******************************/
				cCodBarras := aCB_RN_NN[1]
				/* Formatação da 'Linha Digitável' ********************************/
				cLinhaDig := aCB_RN_NN[2]
			endif

		EndCase

		/******************** INÍCIO DA IMPRESSÃO/GERAÇÃO DO BOLETO *********************/

		oPrn:StartPage()
		nCol := 70

		/*----------------------------------------------------------+
		| Painel Superior - Demonstrativo de Compras/Serviços       |
		+----------------------------------------------------------*/

		//--- Texto fixo da parte superior, recibo
		oPrn:Say(0060,0080+nCol,"DEMONSTRATIVO COMPRAS/SERVIÇOS",oFont1)

		oPrn:Say(0070,1130+nCol,"Fatura Referente  "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),oFont2)
		oPrn:Say(0130,0080+nCol,"Sacado",oFont3)
		oPrn:Say(0160,0080+nCol,Substr(SA1->A1_NOME,1,40),oFont4)
		oPrn:Line(0130,0740+nCol,0200,0740+nCol)
		oPrn:Say(0130,0750+nCol,"CNPJ/CPF",oFont3)
		oPrn:Say(0160,0750+nCol,Iif(SA1->A1_PESSOA=="J",Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@R 999.999.999-99")),oFont4)
		oPrn:Line(0130,1240+nCol,0200,1240+nCol)
		oPrn:Say(0130,1250+nCol,"Vencimento",oFont3)
		oPrn:Say(0160,1250+nCol,Dtoc(SE1->E1_VENCTO),oFont4)
		oPrn:Line(0130,1670+nCol,0200,1670+nCol)
		oPrn:Say(0130,1680+nCol,"Valor Total",oFont3)
		//		oPrn:Say(0160,1680,Transform(SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE,PesqPict("SE1","E1_SALDO")),oFont4) 
		oPrn:Say(0160,1680+nCol,Transform(SE1->E1_VALOR-SE1->E1_DESCONT-SE1->E1_INSS-SE1->E1_VALLIQ+SE1->E1_SDACRES-SE1->E1_SDDECRE,PesqPict("SE1","E1_SALDO")),oFont4)
		oPrn:Line(0130,2140+nCol,0200,2140+nCol)
		oPrn:Say(0130,2150+nCol,"Página",oFont3)
		oPrn:Say(0160,2150+nCol,"01 / 01",oFont4)
		oPrn:Line(0200,0080+nCol,0200,2300)

		oPrn:Box(0270,0080+nCol,2170,1650) // Box Grande 
		//	oPrn:Box(0270,0080+nCol,2054,1650) // Box Grande 		
		oPrn:Say(0290,0080+nCol,"Data",oFont12)
		oPrn:Say(0330,0080+nCol,Dtoc(SE1->E1_VENCTO) ,oFont3,100)
		oPrn:Say(0290,0460+nCol,"Ajuste/Campo/OS Matrícula",oFont12)
		oPrn:Say(0330,0460+nCol,SE1->(E1_PREFIXO+"-"+E1_NUM+"-"+E1_PARCELA) ,oFont3,100)
		oPrn:Say(0290,1400+nCol,"Valor",oFont12)
		oPrn:Say(0330,1450,Transform(SE1->E1_VALOR,PesqPict("SE1","E1_VALOR")),oFont3,100)

		oPrn:Box(0270,1700+nCol,1000,2300) // Box Pequeno Superior Direito
		oPrn:Say(0280,1750+nCol,"INFORMAÇÕES DESTA FATURA",oFont6,100)

		oPrn:Say(0310,1750+nCol,"Cedente: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFont11,100)

		oPrn:Say(0340,1750+nCol,Substr(SM0->M0_NOMECOM,1,30),oFont11,100)
		oPrn:Say(0375,1750+nCol,Substr(SM0->M0_NOMECOM,31,30),oFont11,100)
		oPrn:Say(0410,1750+nCol,Alltrim(Substr(SM0->M0_ENDCOB,1,40)),oFont11,100)
		oPrn:Say(0445,1750+nCol,Alltrim(Substr(SM0->M0_CIDCOB,1,40)) + " " + Substr(SM0->M0_ESTCOB,1,2),oFont11,100)

		nLL := 40
		oPrn:Say(0450+nLL,1750+nCol,"Período: "        + Dtoc(MV_PAR17)+" a "+Dtoc(MV_PAR18) ,oFont3,100)
		oPrn:Say(0510+nLL,1750+nCol,"Título: "         + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA) ,oFont3,100)
		oPrn:Say(0545+nLL,1750+nCol,"Nosso Numero: "   + AllTrim(cNossoNum) + "-" + AllTrim(cDigNNum) ,oFont3,100)
		oPrn:Say(0580+nLL,1750+nCol,"Data Documento: " + Dtoc(SE1->E1_EMISSAO) 			     ,oFont3,100)
		oPrn:Say(0650+nLL,1750+nCol,"Banco: "          + cCodBanco+"-"+SA6->A6_NOME			 ,oFont3,100)
		oPrn:Say(0720+nLL,1750+nCol,"Ag/Cedente: "	   + cCCedente							 ,oFont3,100) //Agência / Código do Beneficiário (Cedente)

		cConvenio := Iif( Len(Alltrim(SEE->EE_CODEMP))==7, "AVULSO", SEE->EE_CODEMP )

		oPrn:Say(0790+nLL,1750+nCol,"Convênio/CAT: "   + cConvenio,oFont3,100)

		//--- Box Pequeno Meio Direito
		oPrn:Box(1050,1700+nCol,1400,2300)
		oPrn:Say(1060,1750+nCol,"Encargos Financeiros Pós Vcto.:",oFont6,100)
		oPrn:Say(1120,1750+nCol,"Multa %:"+Transform(SEE->EE_XMULTA,PesqPict("SEE","EE_XMULTA")),oFont3,100)
		//		oPrn:Say(1170,1750+nCol,"Juros %:"+Transform(SE1->E1_VALJUR,PesqPict("SE1","E1_VALJUR")),oFont3,100)
		oPrn:Say(1170,1750+nCol,"Juros %:"+Transform(SE1->E1_PORCJUR,PesqPict("SE1","E1_PORCJUR")),oFont3,100)
		oPrn:Say(1250,1750+nCol,"Descontos Financeiros até Vcto.:",oFont6,100)
		oPrn:Say(1310,1750+nCol,"Desconto %:"+Transform(SE1->E1_DESCFIN,PesqPict("SE1","E1_DESCFIN")),oFont3,100)

		//--- Box Pequeno Inferior Direito
		oPrn:Box(1450,1700+nCol,1990,2300) 
		//oPrn:Box(1450,1700+nCol,1865,2300)
		oPrn:Say(1460,1760+nCol,"Mensagens:",oFont6,100)

		aObserv := {}
		For nX := 1 to MlCount(AllTrim(SEE->EE_XOBS),24)
			aAdd(aObserv, MemoLine(AllTrim(SEE->EE_XOBS),24,nX))
		Next nX

		nLinAux := 1490
		//nLinAux := 1365

		nTamMem := Iif(Len(aObserv)<=12,Len(aObserv),12)
		For nZ := 1 to nTamMem
			oPrn:Say(nLinAux,1760+nCol,aObserv[nZ],ofont4,100)
			nLinAux += 40
		Next nZ

		oPrn:Line(2030,1700+nCol,2030,2300)
		oPrn:Line(2030,1700+nCol,2100,1700+nCol)
		oPrn:Line(2030,2300,2100,2300)
		oprn:Say(2045,1710+nCol,"Autenticação Mecânica - RECIBO DO SACADO",oFont3,100)

		/*oPrn:Line(1905,1700+nCol,1905,2300)
		oPrn:Line(1905,1700+nCol,1985,1700+nCol)
		oPrn:Line(1905,2300,1985,2300)
		oprn:Say(1920,1710+nCol,"Autenticação Mecânica - RECIBO DO SACADO",oFont3,100)*/

		/*----------------------------------------------------------+
		| Painel Inferior - Boleto                                  |
		+----------------------------------------------------------*/

		// Linha do Canto
		//oPrn:Line(2135,1700+nCol,2900,1700+nCol)
		oPrn:Line(2260,1700+nCol,3070,1700+nCol)                                                  

		/* Linha 1 **************************************************/
		//Linhas Pequenas do Meio
		//nLin := 2273
		nLin := 2408
		oPrn:Say(nLin,0360+nCol,"|",ofont3,100)
		oPrn:Say(nLin,0710+nCol,"|",ofont3,100)
		oPrn:Say(nLin,0860+nCol,"|",ofont3,100)
		oprn:Say(nLin,1070+nCol,"|",ofont3,100)
		nLin += 20
		oPrn:Say(nLin,0360+nCol,"|",ofont3,100)
		oPrn:Say(nLin,0710+nCol,"|",ofont3,100)
		oPrn:Say(nLin,0860+nCol,"|",ofont3,100)
		oprn:Say(nLin,1070+nCol,"|",ofont3,100)
		nLin += 20
		oPrn:Say(nLin,0360+nCol,"|",ofont3,100)
		oPrn:Say(nLin,0710+nCol,"|",ofont3,100)
		oPrn:Say(nLin,0860+nCol,"|",ofont3,100)
		oprn:Say(nLin,1070+nCol,"|",ofont3,100)
		nLin += 20
		oPrn:Say(nLin,0360+nCol,"|",ofont3,100)
		oprn:Say(nLin,1070+nCol,"|",ofont3,100)
		nLin += 10
		oprn:Say(nLin,0510+nCol,"|",ofont3,100)
		oprn:Say(nLin,0660+nCol,"|",ofont3,100)
		nLin += 10
		oPrn:Say(nLin,0360+nCol,"|",ofont3,100)
		oprn:Say(nLin,1070+nCol,"|",ofont3,100)
		nLin += 5
		oprn:Say(nLin,0510+nCol,"|",ofont3,100)
		oprn:Say(nLin,0660+nCol,"|",ofont3,100)
		nLin += 20
		oPrn:Say(nLin,0360+nCol,"|",ofont3,100)
		oprn:Say(nLin,1070+nCol,"|",ofont3,100)
		nLin += 2
		oprn:Say(nLin,0510+nCol,"|",ofont3,100)
		oprn:Say(nLin,0660+nCol,"|",ofont3,100)

		nLin := 2180
		//nLin := 2055
		oprn:Say(nLin,0050+nCol,replicate(" - ",140),oFont3,100) 						// Linha
		nLin += 30

		//oprn:Say(nLin,0085+nCol,Substr(SA6->A6_NOME,1,35),ofont9,100)
		
		oPrn:Say(nLin,0080+nCol,Substr(SA6->A6_NOME,1,35),ofont9,100)
		
		/*
		If File(cBMP_Caixa) .And. cCodbanco = '104' .And. SubStr(SE1->E1_FILIAL,3,2) == "MG" 
			oPrn:SayBitmap(nLin,0080+nCol,cBMP_Caixa,207,40)
		ElseIf File(cBMP_SICOOB) .And. cCodbanco = '756'
			oPrn:SayBitmap(nLin,0080+nCol,cBMP_SICOOB,207,40)
		ElseIf File(cBMP_BRASIL) .And. cCodbanco = '001'
			oPrn:SayBitmap(nLin,0080+nCol,cbmp_brasil,207,40)	
		Endif	
		*/
		oprn:Say(nLin,0600+nCol,"| "+cCodBanco+"-"+cDVBanco+" |",ofont1,100)

		oPrn:Say(nLin,0850+nCol,cLinhaDig,oFont14,100)									// Linha Digitável
		nLin += 50

		oPrn:Line(nLin,0050+nCol,nLin,2300)
		//2360
		nLin += 10

		/* Linha 2 **************************************************/
		oprn:Say(nLin,0080+nCol,"Local de pagamento",ofont3,100)
		oprn:Say(nLin,1720+nCol,"Vencimento",ofont3,100)
		nLin += 30
		If cCodBanco == "756"															// SICOOB
			oprn:Say(nLin,0080+nCol,"PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO",ofont6,100)				// Local de pagamento
		Else
			oprn:Say(nLin,0080+nCol,"PREFERENCIALMENTE DAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE",ofont6,100)  // Local de pagamento
		EndIf
		oPrn:Say(nLin,1780+nCol,Dtoc(SE1->E1_VENCTO),ofont6,100)						// Vencimento
		nLin += 30
		oPrn:Line(nLin,0050+nCol,nlin,2300)
		//2450
		nLin += 10

		/* Linha 3 **************************************************/
		If cCodBanco == "756"															// SICOOB
			oPrn:Say(nLin,0080+nCol,"Cedente",ofont3,100)
			oPrn:Say(nLin,1720+nCol,"Agência/Código do Cedente",ofont3,100)
		Else
			oPrn:Say(nLin,0080+nCol,"Beneficiário",ofont3,100)
			oPrn:Say(nLin,1720+nCol,"Agência / Código do Beneficiário",ofont3,100)
		EndIf
		nLin += 30
		If cCodBanco == "756"															// SICOOB
			oPrn:Say(nLin,0080+nCol,Alltrim(SM0->M0_NOMECOM),ofont6,100) 				// Beneficiário (Cedente)
		Else
			oPrn:Say(nLin,0080+nCol,Alltrim(SM0->M0_NOMECOM)+"  CNPJ:"+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+"  "+ SM0->M0_ENDCOB ,ofont6,100) //Beneficiário (Cedente)
		EndIf
		oPrn:Say(nLin,1780+nCol,cCCedente			,ofont4,100) 					// Agência / Código do Beneficiário (Cedente)
		nLin += 30
		oPrn:Line(nLin,0050+nCol,nLin,2300)
		//2520
		nLin += 10

		/* Linha 4 **************************************************/
		oPrn:Say(nLin,0080+nCol,"Data do Documento"	,ofont3,100)
		oPrn:Say(nLin,0370+nCol,"Nr. do Documento"	,ofont3,100)
		oPrn:Say(nLin,0720+nCol,"Espécie Doc."		,ofont3,100)
		oprn:Say(nLin,0870+nCol,"Aceite"			,ofont3,100)
		oprn:Say(nLin,1080+nCol,"Data do Processamento",ofont3,100)
		oprn:Say(nLin,1720+nCol,"Nosso Número"		,ofont3,100)
		nLin += 30
		oPrn:Say(nLin,0080+nCol,Dtoc(SE1->E1_EMISSAO),ofont4,100)						// Data do documento
		oPrn:Say(nLin,0370+nCol,SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,ofont4,100) // Nr. do documento  
		If SubStr(xFilial("SE1"), 3, 2) <> "BA" 
			oPrn:Say(nLin,0720+nCol,SE1->E1_TIPO,ofont4,100)							// Espécie doc.
		Else	                                                                                            
			oPrn:Say(nLin,0720+nCol,"DS",ofont4,100)									// Espécie doc.
		Endif	
		oPrn:Say(nLin,0870+nCol,"N",ofont4,100)											// Aceite
		oprn:Say(nLin,1090+nCol,Dtoc(dDataBase),ofont4,100)								// Data do processamento
		If cBanco == "756"
		oPrn:Say(nLin,1780+nCol,AllTrim(cNossoNum) + "-" + AllTrim(cDigNNum),ofont4,100)// Nosso Número		// Comentado Aleluia 080818
		Else
		oPrn:Say(nLin,1780+nCol,AllTrim(cNossoNum),ofont4,100)// Nosso Número
		EndIf
		nLin += 30
		oPrn:Line(nLin,0050+nCol,nLin,2300)
		//2590
		nLin += 10

		/* Linha 5 **************************************************/
		oprn:Say(nLin,0080+nCol,"Uso do Banco"		,ofont3,100)
		oprn:Say(nLin,0370+nCol,"Carteira"			,ofont3,100)
		oprn:Say(nLin,0520+nCol,"Espécie Moeda"			,ofont3,100)
		oprn:Say(nLin,0670+nCol,"Quantidade"		,ofont3,100)
		oprn:Say(nLin,1090+nCol,"Valor"				,ofont3,100)
		oPrn:Say(nLin,1720+nCol,"(=) Valor do Documento",ofont3,100)
		nLin += 30
		If SubStr(xFilial("SE1"), 3, 2) <> "BA" 										//Ana
			oprn:Say(nLin,370+nCol,SEE->EE_XCART		,ofont4,100)         			// Carteira
		ElseIf cCodBanco == "756"														// SICOOB
			oprn:Say(nLin,370+nCol,PadL(cCartCob,3,"0") + "-" + PadL(cModalid,3,"0"),ofont4,100)	// Espécie doc. Sicoob - Carteira + Modalidade
		Else
			oprn:Say(nLin,370+nCol,"RG",ofont4,100)         							// Carteira			
		Endif	
		oprn:Say(nLin,520+nCol,"R$"					,ofont4,100)						// Espécie 

		//oprn:Say(nLin,680+nCol,"DS"					,ofont4,100)					// Quantidade
		oPrn:Say(nLin,1780+nCol,Transform( SE1->E1_VALOR + SE1->E1_SDACRES - SE1->E1_SDDECRE - ;
		SE1->E1_DESCONT - SE1->E1_INSS - SE1->E1_VALLIQ, PesqPict("SE1","E1_SALDO") ) ,oFont4,100)	// Valor do Documento
		nLin += 30
		oPrn:Line(nLin,0050+nCol,nLin,2300)
		//2660
		nLin += 10

		/* Linha 6 **************************************************/
		If cCodBanco == "756"														// SICOOB
			oprn:Say(nLin,0080+nCol,"Instruções (Texto de responsabilidade do Cedente)",ofont6,100)
		Else
			oprn:Say(nLin,0080+nCol,"Instruções (Texto de responsabilidade do Beneficiário):",ofont6,100)
		EndIf

		oprn:Say(nLin,1720+nCol,"(-) Desconto",ofont3,100)
		nLin += 30
		nLinMsg := nLin + 15
		/*/Inicio 
		oprn:Say(nLinMsg,0080+nCol,"Os pagamentos efetuados fora do prazo estão sujeitos à incidência de multa de 2,0% (dois por cento)",ofont13,100)
		nLinMsg += 45                                                                                                              
		oprn:Say(nLinMsg,0080+nCol,"sobre o valor vencido, acrescido de juros 1,0% (hum por cento) ao mês, (Valor original + Juros).",ofont13,100)
		*///Fim       

		//Mensagem por campo no cadastro de parametros do banco   
		oprn:Say(nLinMsg,0080+nCol,Alltrim(SEE->EE_xOBS1) ,ofont3,100)
		nLinMsg += 45                                                                                                              
		oprn:Say(nLinMsg,0080+nCol,Alltrim(SEE->EE_xOBS2),ofont3,100)

		nLinMsg += 45 
		//nLinMsg += 45 
		nLinMsg += 45               

		//oprn:Say(nLinMsg,0080+nCol,"Caso este título não seja pago até o vencimento será encaminhado aos Órgãos de Proteção ao",ofont13,100)
		//nLinMsg += 45
		//oprn:Say(nLinMsg,0080+nCol,"Crédito. NÃO RECEBER APÓS 120 DIAS DO VENCIMENTO.",ofont13,100)

		oprn:Say(nLinMsg,0080+nCol,Alltrim(SEE->EE_xOBS3),ofont3,100)
		nLinMsg += 45
		oprn:Say(nLinMsg,0080+nCol,Alltrim(SEE->EE_xOBS4),ofont3,100)

		nLin += 30
		oPrn:Line(nlin,1707+nCol,nLin,2300)                    
		//2730                                                                                                                          

		nLin += 10
		oprn:Say(nLin,1720+nCol,"(-) Outras Deduções/Abatimento",ofont3,100)
		nLin += 60
		oPrn:Line(nLin,1707+nCol,nLin,2300)
		nLin += 10
		oprn:Say(nLin,1720+nCol,"(+) Mora/Multa/Juros",ofont3,100)
		nLin += 60
		oPrn:Line(nLin,1707+nCol,nLin,2300)
		nLin += 10
		oprn:Say(nLin,1720+nCol,"(+) Outros Acréscimos",ofont3,100)
		nLin += 60
		oPrn:Line(nLin,1707+nCol,nLin,2300)
		nLin += 10
		oprn:Say(nLin,1720+nCol,"(=) Valor Cobrado",ofont3,100)
		//2950

		nLin += 70
		oPrn:Line(nLin,0050+nCol,nLin,2300)
		nLin += 10

		/* Rodapé - Informações do SACADO ***************************/
		oPrn:Say(nLin,0080+nCol,"Sacado:",ofont3,100)
		nLin += 20
		oPrn:Say(nLin,0080+nCol,Alltrim(SA1->A1_NOME)+" - CNPJ:"+Iif(SA1->A1_PESSOA=="J",transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),transform(SA1->A1_CGC,"@R 999.999.999-99")),oFont4,100)
		nLin += 40
		oPrn:Say(nLin,0080+nCol,Alltrim(SA1->A1_END)+" - "+Alltrim(SA1->A1_BAIRRO),ofont4,100)
		nLin += 40
		oPrn:Say(nLin,0080+nCol,Transform(SA1->A1_CEP,PesqPict("SA1","A1_CEP"))+" - "+Alltrim(SA1->A1_MUN)+" - "+SA1->A1_EST,oFont4,100)
		nLin += 42                   
		oPrn:Say(nLin,0080+nCol,"Sacador/Avalista"	,oFont3,100)
		oPrn:Say(nLin,1750+nCol,"Código de Baixa:"	,oFont3,100)
		nLin += 20
		oPrn:Line(nLin,0050+nCol,nLin,2300)
		nLin += 18    //Era 30
		oPrn:Say(nLin,1600+nCol,"Autenticação mecânica - FICHA DE COMPENSAÇÃO",oFont3,100)

		//MSBAR("INT25",26.7,0.9,cCodBarras,oPrn,.F.,,.T.,0.027,1.5,NIL,NIL,NIL,.F.) 		// CÓDIGO DE BARRAS
		//MSBAR("INT25",26.7,2.0,cCodBarras,oPrn,.F.,,.T.,0.027,1.5,NIL,NIL,NIL,.F.) 		// CÓDIGO DE BARRAS   
		MSBAR3("INT25",26.2,1.5,cCodBarras,oPrn,.F.,,.T.,0.027,1.3,NIL,NIL,NIL,.F.) 		// CÓDIGO DE BARRAS
		//MSBAR("INT25",26.7,1.0,cCodBarra,oPrn,.F.,,.T.,0.027,1.3,NIL,NIL,NIL,.F.) // Posicao do Codigo

		/*
		Parametros
		01 cTypeBar String com o tipo do codigo de barras           
		EAN13, EAN8, UPCA, SUP5, CODE128, INT25, MAT25, IND25, CODABAR, CODE3_9              
		02 nRow		Numero da Linha em centimentros                
		03 nCol		Numero da coluna em centimentros			   
		04 cCode	String com o conteudo do codigo                
		05 oPr		Objeto Printer                                
		06 lcheck	Se calcula o digito de controle                
		07 Cor 		Numero da Cor, utilize a "common.ch"          
		08 lHort	Se imprime na Horizontal                       
		09 nWidth	Numero do Tamanho da barra em centimetros      
		10 nHeigth	Numero da Altura da barra em milimetros        
		11 lBanner	Se imprime o linha em baixo do codigo          
		12 cFont	String com o tipo de fonte                     
		13 cMode	String com o modo do codigo de barras CODE128  
		*/

		/*If _VersoBol == '1' // 27/04/2017 Criado parametro para controle de tratamento de impressao no verso 
		//com impressora que imprime em frente e verso para envio pelo correio

		If (SubStr(xFilial("SE1"), 3, 2) <> "MT")
		oPrn:StartPage()

		If File(cBmp)
		oPrn:SayBitmap(0010,0020,cBmp,2700,3200)
		EndIf

		//Destinatario
		cCodCep := CalcCep(SA1->A1_CEPC)
		oPrn:Say(1150,0550,cCodCep,oFontCep,100)
		oPrn:Say(1210,0550,"DESTINATÁRIO:",oFont9,100)
		oPrn:Say(1270,0550,SA1->A1_NOME,oFont9,100)
		oPrn:Say(1350,0550,SA1->A1_ENDCOB,oFont9,100)
		oPrn:Say(1400,0550,SA1->A1_BAIRROC,oFont9,100)
		oPrn:Say(1450,0550,Transform(SA1->A1_CEPC,PesqPict("SA1","A1_CEPC"))+" "+SA1->(A1_MUNC+" "+A1_ESTC),oFont9,100)

		_nLin:=1150
		//Destinatario
		oPrn:Say(1210+_nLin,0550,"REMETENTE:",oFont9,100)
		oPrn:Say(1270+_nLin,0550,SM0->M0_NOMECOM,oFont9,100)
		oPrn:Say(1350+_nLin,0550,SM0->M0_ENDCOB,oFont9,100)
		oPrn:Say(1400+_nLin,0550,SM0->M0_BAIRCOB,oFont9,100)
		oPrn:Say(1450+_nLin,0550,Transform(SM0->M0_CEPCOB,PesqPict("SA1","A1_CEPC"))+" "+SM0->(M0_CIDCOB+" "+M0_ESTCOB),oFont9,100)

		Endif
		Endif */

		oPrn:EndPage()               

		/********************** FIM DA IMPRESSÃO/GERAÇÃO DO BOLETO *********************/ 

		(cAliasTRB)->(dbSkip())
	EndDo


	//oPrn:Setup()
	//oPrn:Preview()

Return .T.

/*/{Protheus.doc} ValidPerg
// Função STATIC Cria as perguntas 

@author 	luciano.camargo
@since 		27/04/2017
@version 	P11.8
@param 		cPerg, characters, descricao
@type 		function

/*/

Static Function ValidPerg(cPerg)

	Local _sAlias := Alias()
	Local aRegs := {}
	Local i,j

	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05

	aAdd(aRegs,{cPerg,"01","Banco:  "				,"mv_ch1","C",03,0,0,"G","naoVazio()","mv_par01","","","","","","","","","","","","","","","SA6","007",{"Código do Banco"},{"Código do Banco"},{"Código do Banco"}})
	aAdd(aRegs,{cPerg,"02","Agencia: "				,"mv_ch2","C",05,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","","008",{"Código da agencia do banco"},{"Código da Agencia do banco"},{"Código da Agencia do banco"}})
	aAdd(aRegs,{cPerg,"03","Conta: "				,"mv_ch3","C",10,0,0,"G","naovazio()","mv_par03","","","","","","","","","","","","","","","","009",{"Conta corrente"},{"Conta corrente"},{"Conta corrente"}})
	aAdd(aRegs,{cPerg,"04","SubConta:  "			,"mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","",{"Código da SubConta"},{"Código da SubConta"},{"Código da SubConta"}})
	aAdd(aRegs,{cPerg,"05","Prefixo de:  "			,"mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","",{"Prefixo do título a receber inicial"},{"Prefixo do título a receber inicial"},{"Prefixo do título a receber"}})
	aAdd(aRegs,{cPerg,"06","Prefixo até: "			,"mv_ch6","C",03,0,0,"G","naovazio()","mv_par06","","","","","","","","","","","","","","","","",{"Prefixo do título a receber final"},{"Prefixo do título a receber final"},{"Prefixo do título a receber"}})
	aAdd(aRegs,{cPerg,"07","Título inicial: "		,"mv_ch7","C",09,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","018",{"Numero do titulo inicial"},{"Numero do titulo inicial"},{"Numero do titulo de"}})
	aAdd(aRegs,{cPerg,"08","Título final: "			,"mv_ch8","C",09,0,0,"G","naovazio()","mv_par08","","","","","","","","","","","","","","","","018",{"Numero do titulo final"},{"Numero do titulo final"},{"Numero do titulo de"}})
	aAdd(aRegs,{cPerg,"09","Parcela inicial: "		,"mv_ch9","C",TamSx3("E1_PARCELA")[1],0,0,"G","","mv_par09","","","","","","","","","","","","","","","","011",{"Parcela inicial"},{"Parcela inicial"},{"Parcela de"}})
	aAdd(aRegs,{cPerg,"10","Parcela final: "		,"mv_cha","C",TamSx3("E1_PARCELA")[1],0,0,"G","naovazio()","mv_par10","","","","","","","","","","","","","","","","011",{"Parcela final"},{"Parcela final"},{"Parcela ate"}})
	aAdd(aRegs,{cPerg,"11","Tipo inicial: "			,"mv_chb","C",03,0,0,"G","","mv_par11","","","","","","","","","","","","","","","05","",{"Tipo do titulo inicial"},{"Tipo do titulo inicial"},{"Tipo do titulo de"}})
	aAdd(aRegs,{cPerg,"12","Tipo final: "			,"mv_chc","C",03,0,0,"G","naovazio()","mv_par12","","","","","","","","","","","","","","","05","",{"Tipo do titulo final"},{"Tipo do titulo final"},{"Tipo do titulo ate"}})
	aAdd(aRegs,{cPerg,"13","Cliente inicial: "		,"mv_chd","C",TamSx3("A1_COD")[1],0,0,"G","","mv_par13","","","","","","","","","","","","","","","SA1CLI","001",{"Cliente inicial"},{"Cliente inicial"},{"Cliente inicial"}})
	aAdd(aRegs,{cPerg,"14","Cliente final: "		,"mv_che","C",TamSx3("A1_COD")[1],0,0,"G","NaoVazio()","mv_par14","","","","","","","","","","","","","","","SA1CLI","001",{"Cliente final"},{"Cliente final"},{"Cliente ate"}})
	aAdd(aRegs,{cPerg,"15","Loja inicial: "			,"mv_chf","C",TamSx3("A1_LOJA")[1],0,0,"G","","mv_par15","","","","","","","","","","","","","","","","002",{"Loja inicial"},{"Loja inicial"},{"Loja de"}})
	aAdd(aRegs,{cPerg,"16","Loja final: "			,"mv_chg","C",TamSx3("A1_LOJA")[1],0,0,"G","NaoVazio()","mv_par16","","","","","","","","","","","","","","","","002",{"Loja final"},{"Loja final"},{"Loja ate"}})
	aAdd(aRegs,{cPerg,"17","Vencimento de: "		,"mv_chh","D",08,0,0,"G","NaoVazio()","mv_par17","","","","","","","","","","","","","","","","",{"Data de vencimento real do titulo de"},{"Data de vencimento real do titulo de"},{"Data de vencimento real do titulo de"}})
	aAdd(aRegs,{cPerg,"18","Vencimento até: "		,"mv_chi","D",08,0,0,"G","NaoVazio()","mv_par18","","","","","","","","","","","","","","","","",{"Data de vencimento real do titulo ate"},{"Data de vencimento real do titulo ate"},{"Data de vencimento real do titulo ate"}})
	aAdd(aRegs,{cPerg,"19","Numero Borderô Ini: "	,"mv_chj","C",TamSx3("E1_NUMBOR")[1],0,0,"G","","mv_par19","","","","","","","","","","","","","","","SA1CLI","001",{"Bordero inicial"},{"Bordero inicial"},{"Bordero inicial"}})
	aAdd(aRegs,{cPerg,"20","Numero Borderô Fim: "	,"mv_chl","C",TamSx3("E1_NUMBOR")[1],0,0,"G","NaoVazio()","mv_par20","","","","","","","","","","","","","","","SA1CLI","001",{"Bordero final"},{"Bordero final"},{"Bordero ate"}})


	For i := 1 to Len(aRegs)
		PutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,4],aRegs[i,5],aRegs[i,6],aRegs[i,7],;
		aRegs[i,8],aRegs[i,9],aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
		aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
		aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24],aRegs[i,29],aRegs[i,29],aRegs[i,30])
	Next i

	dbSelectArea(_sAlias)

Return

/*/{Protheus.doc} SIFR03In
//Marca / Desmarca todas as Filiais

@author 	luciano.camargo
@since 		27/04/2017
@version 	P11.8
@param 		oMark, object, descricao
@param 		cAliasTRB, characters, descricao
@type 		function

/*/

User Function SIFR03In( oMark,cAliasTRB )

	Local nRec := (cAliasTRB)->( Recno() )

	dbSelectArea(cAliasTRB)
	dbGoTop()

	While !EOF(cAliasTRB)

		RecLock(cAliasTRB, .F. )
		(cAliasTRB)->E1_OK := If( (cAliasTRB)->E1_OK == cMarca, "", cMarca )
		MsUnlock()
		dbSkip()

	EndDo

	(cAliasTRB)->( DbGoTo( nRec ) )
	lInverte := !lInverte

	oMark:oBrowse:Refresh()

Return Nil

/*/{Protheus.doc} FINR03VB
//Critica: O Banco deve ser o mesmo que foi selecionado na tela anterior

@author 	luciano.camargo
@since 		27/04/2017
@version 	P11.8
@type 		function

/*/

User Function FINR03VB()

	Local lRet := .T.

	If Alltrim(MV_PAR01) <> Alltrim(cCodBanco)
		MsgStop("O Banco deve ser o mesmo que foi selecionado na tela anterior.","Atenção")
		lRet := .F.
	Endif

Return lRet


/*/{Protheus.doc} FIN03ini
//Critica: O banco selecionado nao está cadastrado para esta Filial

@author 	luciano.camargo
@since 		27/04/2017
@version 	P11.8
@type 		function

/*/

User Function FIN03ini()

	Local lRet := .T.

	If !(SA6->(dbSeek(xFilial("SA6")+mv_par01+mv_par02+mv_par03)))
		MsgStop("Este Banco, Agência e Conta ("+rtrim(mv_par01)+"/"+rtrim(mv_par02)+"/"+rtrim(mv_par03)+") nao está cadastrado para esta Filial.","Banco não cadastrado")
		lRet := .F.
	Endif

Return lRet

/*/{Protheus.doc} SIFR03Cg
//Inverte Selecao de titulos

@author 	luciano.camargo
@since 		27/04/2017
@version 	P11.8
@param 		oMark, object, descricao
@param 		cAliasTRB, characters, descricao
@type 		function

/*/

User Function SIFR03Cg( oMark,cAliasTRB )

	Local nRec  := (cAliasTRB)->( Recno() )
	Local cFlag := " "

	dbSelectArea(cAliasTRB)
	dbGoTop()

	While !EOF(cAliasTRB)

		If IsMark( "E1_OK" , cMarca , lInverte )
			cFlag := " "
		Else
			cFlag := cMarca
		EndIf

		RecLock(cAliasTRB, .F. )
		(cAliasTRB)->E1_OK := cFlag
		MsUnlock()
		dbSkip()

	EndDo

	(cAliasTRB)->( DbGoTo( nRec ) )
	oMark:oBrowse:Refresh()

Return Nil

/*/{Protheus.doc} CalcCep
//Calculo do Digito Verificador do CEP (PostNet)

@author 	luciano.camargo
@since 		27/04/2017
@version 	P11.8
@param 		cCep, characters, descricao
@type 		function

/*/

Static Function CalcCep(cCep)

	Local cRet := ""
	Local nDig := 0
	Local nX

	For nX:=1 to Len(cCep)
		nDig:=nDig+Val(SUBSTR(cCep,nX,1))
	Next nX

	nDig := Iif(nDig>9,Val(SUBSTR(Str(nDig),Len(Str(nDig)),1)),nDig)
	nDig := Abs(Iif(nDig==0,nDig,10-nDig))
	cRet := "/"+cCep+Alltrim(Str(nDig))+"\"

Return(cRet)

/*/{Protheus.doc} Modulo10
//Calcula o digito verificador, Módulo 10, usando pesos 2 e 1 alternadamente.
@author 	luciano.camargo
@since 		27/04/2017
@version 	P11.8
@param 		cString, characters, descricao
@obs 		Calcula o digito verificador, Módulo 10, usando pesos 2 e 1 alternadamente.
@history  	27/04/17, Luciano Camargo - TOTVS, Criação
@history  	31/05/17, Kley@TOTVS, Melhorias
@type 		function
/*/

User Function Modulo10(cString)

	Local nCont	  :=0
	Local cRet 	  := ""
	Local nDigito := 0
	Local nX
	Local nPeso   := 2

	cString:= Alltrim(cString)

	For nX := Len(cString) to 1 Step -1

		If nPeso == 2
			If Val(Substr(cString,nX,1))*nPeso >= 10
				nVal  := Val(SUBSTR(cString,nX,1))*nPeso
				nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
			Else
				nCont:=nCont+(Val(SUBSTR(cString,nX,1))*nPeso)
			Endif
		Else
			nCont:=nCont+(Val(SUBSTR(cString,nX,1))*nPeso)
		Endif

		If nPeso == 1
			nPeso := 2
		Else
			nPeso := nPeso-1
		Endif

	Next nX

	nDigito:=Abs(If((nCont%10)==0,0,10-(nCont%10)))
	cRet := Str(nDigito,1)

Return(cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} Mod11Sic
Calcula o digito verificador de uma sequencia de numeros baseando-se 
no modulo 11 com constante para cálculo para o SICOOB.
@author Kley@TOTVS.com.br
@since 08/03/2018
@version 1.0
@type	   function
@param	   cNum   = Sequencia de números para cálculo do dígito verificar.
@return nDV, numérico, Dígito Verificador
@example Mod11Sic( cNum )
@obs Uso na FIEMG
/*/
//-------------------------------------------------------------------

Static Function Mod11Sic( cNum )

	Local nFor    	:= Len(cNum)
	Local nTot    	:= 0
	Local aNumAux 	:= Array(Len(cNum),3)	// array com o conteudo do cNum para ser multiplicado
	Local aLisMult	:= {3,1,9,7} 			// array com a Constante de Multiplicadores
	Local nModulo  
	Local nDV   
	Local nPos 	  	:= 1

	For nFor := 1 to Len(cNum)
		aNumAux[nFor,1] := Val(SubStr(cNum,nFor,1))
		aNumAux[nFor,2] := aLisMult[nPos]
		nPos++
		If nPos > Len(aLisMult)
			nPos := 1
		EndIf
		aNumAux[nFor,3] := aNumAux[nFor,2] * aNumAux[nFor,1]
		nTot += aNumAux[nFor,3]
	Next

	nModulo := Mod(nTot, 11)

	If nModulo == 0 .or. nModulo == 1
		nDV := 0
	Else 
		nDV := 11 - nModulo
	EndIf

	Return Str(nDV,1)


	/*/{Protheus.doc} CodBarra - OBSOLETA [Tratamento no corpo da função principal]
	//Funcao que monta o codigo de barra no modelo INT25.

	@author 	luciano.camargo
	@since 		27/04/2017
	@version 	P11.8
	@type 		function
	@description 

	A variavel cCodBar define o Codigo de Barras para COB,sendo   
	formada da sequinte forma:                                    

	Posicao    Quantidade       Descricao                         
	- POSICOES FIXAS PADRAO BANCO CENTRAL                        
	01 a 03   03   Codigo de Compensacao do Banco		          
	04 a 04   01   Codigo da Moeda(9-R$)                         
	05 a 05   01   D.V. (digito verificador do codigo de barras) 
	06 a 09   04   Fator de Vencimento                           
	10 a 19   10   Valor Nominal do Documento sem ponto          

	/*/
	/*
	Static Function CodBarra()

	Local nDig 	  := 0
	//Local cFator  := ALLTRIM(STR(SE1->E1_VENCREA - CTOD("07/10/1997")))  // Fator de Vencimento
	Local cFator  := ALLTRIM(STR(SE1->E1_VENCTO - CTOD("07/10/1997")))  // Fator de Vencimento
	Local cCampoLivre := CampoLivre(cCodBanco)
	Local cCodBar := ""
	Local lMais10 := Iif(SE1->E1_SALDO>9999999.99,.T.,.F.)
	Local nSaldo  := (SE1->E1_VALOR-SE1->E1_DESCONT-SE1->E1_INSS-SE1->E1_VALLIQ+SE1->E1_SDACRES-SE1->E1_SDDECRE)*100

	If lMais10
	cCodBar := cCodBanco+"9"+StrZero(Int(nSaldo),14)+cCampoLivre
	Else
	//cCodBar := cCodBanco+"9"+cFator+StrZero(Int(nSaldo),10)+cCampoLivre    
	cCodBar := cCodBanco+"9"+cFator+StrZero(Int(NoRound(nSaldo,0)),10)+cCampoLivre  
	Endif

	nDig 	:= DigCodBar(cCodBar)
	cCodBar := Substr(cCodBar,1,4)+nDig+Substr(cCodBar,5,39)

	Return(cCodBar)
	*/

	/*/{Protheus.doc} DigCodBar - OBSOLETA [Tratamento no corpo da função principal]
	//Funcao que gera o Digito Verificador do Codigo de barra MOD(11) Pesos (2 a 9)

	@author 	luciano.camargo
	@since 		27/04/2017
	@version 	P11.8
	@param 		cCodBar, characters, descricao
	@type 		function

	/*/
	/*
	Static Function DigCodBar(cCodBar)

	Local nCont	:= 0
	Local nPeso	:= 2
	Local nResto:= 0
	Local nRet 	:= 0

	For i:=Len(cCodBar) To 1 Step -1
	nCont:=nCont+(Val(SUBSTR(cCodBar,i,1))*nPeso)
	nPeso:=nPeso+1
	if nPeso>9
	nPeso:=2
	endif
	Next i

	nResto:=(nCont%11)
	nResto:=11-nResto

	If nResto==0 .or. nResto==1 .or. nResto > 9
	nRet:='1'
	Else
	nRet:=Str(nResto,1)
	Endif

	Return(nRet)
	*/

	/*/{Protheus.doc} CampoLivre - OBSOLETA [Tratamento no corpo da função principal]
	//Funcao que gera o Campo Livre para Cada Banco

	@author 	luciano.camargo
	@since 		27/04/2017
	@version 	P11.8
	@param 		cCodBanco, characters, descricao
	@type 		function
	@obs 		Usado pela CodBarra()

	/*/
	/*
	Static Function CampoLivre(cCodBanco)

	Local cRet := ""
	Local cAux := ""

	Do Case
	Case cCodBanco == '001' // Banco do Brasil
	//  BB
	//   - POSICOES LIVRES DO BCO (CAMPO LIVRE)                       
	//   20 a 30   11   Nosso Numero (Sem DV)                         
	//   31 a 34   04   Nr. Agencia Cedente                           
	//   35 a 42   08   Nr. Conta Corrente (Sem DV)                   
	//   43 a 44   02   Carteira                			          
	If  Len(Alltrim(SEE->EE_CODEMP)) < 7
	If Alltrim(SEE->EE_XCART) $ "16|18" .and.  Len(Alltrim(SEE->EE_CODEMP))== 6  .And. !(Empty(SEE->EE_xNOSNUM))
	cRet := Substr(SEE->EE_CODEMP,1,6)+Substr(SE1->E1_XNUMBCO,1,17)+"21"
	Else
	//				cRet := Substr(SE1->E1_NUMBCO,1,11)+Substr(MV_PAR02,1,4)+Substr(MV_PAR03,1,8)+Substr(SEE->EE_XCART,1,2) //esta ok 
	cRet := Substr(SE1->E1_NUMBCO,1,11)+StrZero(Val(MV_PAR02),4)+StrZero(Val(MV_PAR03),8)+Substr(SEE->EE_XCART,1,2) //esta ok
	Endif
	Else
	If !Empty(SE1->E1_XIDCNAB)                                                      
	//Ana: quando o nosso numero vem do Legado ja contem o codigo da empresa no campo xidcnab.                                        
	cRet := "000000"+Substr(SE1->E1_xIDCNAB,1,17)+Substr(SEE->EE_XCART,1,2)
	Else			                                                                              
	//Ana: quando o nosso numero eh gerado no Protheus.
	cRet := "000000"+Substr(SEE->EE_CODEMP,1,7)+Substr(SE1->E1_NUMBCO,1,10)+Substr(SEE->EE_XCART,1,2) //Ana - Verificar
	Endif
	Endif
	Case cCodBanco == '104'// CEF
	//  CEF
	//   - POSICOES LIVRES DO BCO (CAMPO LIVRE)                       
	//   20 a 25   06   Codigo Cedente                                
	//   26 a 26   01   DV Codigo do Cedente                          
	//   27 a 29   03   Nosso Numero Sequencia 1                      
	//   30 a 30   01   Constante "1"                  			      
	//   31 a 33   03   Nosso Numero Sequencia 2                      
	//   34 a 34   01   Constante "2"                  			      
	//   35 a 43   09   Nosso Numero Sequencia 3                      
	//   44 a 44   01   DV do Campop Livre           			      
	//cRet := Substr(SE1->E1_NUMBCO,1,10)+Substr(MV_PAR02,1,4)+"003"+"000"+Substr(MV_PAR03,1,5)
	//cRet := Substr(MV_PAR03,1,6)+Alltrim(SA6->A6_DVCTA)+Alltrim(Substr(StrZero(val(cNossonum),17),1,3))+Substr(SEE->EE_XCART,1,1)+Alltrim(Substr(StrZero(val(cNossonum),17),4,3))+Substr(SEE->EE_XCART,2,1)+Alltrim(Substr(StrZero(val(cNossonum),15),7,9))
	cRet := Substr(MV_PAR03,1,6)+"0431"+"87"+SUBSTR(SE1->E1_NUMBCO,2,14) //Alterado em 15/01 conforme solicitacao da Valeria.
	cAux := DigMod11(cRet,20,90)
	cRet := Alltrim(cRet)+cAux
	Case cCodBanco == '341' // Itau
	//  ITAU
	//   - POSICOES LIVRES DO BCO (CAMPO LIVRE)                       
	//   20 a 22   03   Carteira                                      
	//   23 a 30   08   Nosso Numero                                  
	//   31 a 31   01   DAC (Agencia/Conta/Carteira/Nosso Numero      
	//   32 a 35   04   Nr. da Agencia Cedente					      
	//   36 a 40   05   Nr. da Conta Corrente   			          
	//   41 a 41   01   DAC (Agencia/Conta Corrente)		          
	//   42 a 44   03   Zeros								          
	cRet := Substr(SEE->EE_XCART,1,3)+Substr(SE1->E1_NUMBCO,1,8)+cDigNNum+Substr(MV_PAR02,1,4)+Substr(MV_PAR03,1,5)+Alltrim(SA6->A6_DVCTA)+"000"
	Case cCodBanco == '033'// Santander
	//  SANTANDER
	//   - POSICOES LIVRES DO BCO (CAMPO LIVRE)                       
	//   20 a 20   01   Fixo "9"                                      
	//   21 a 27   07   Codigo Cedente                                
	//   28 a 40   13   Nosso Numero                                  
	//   41 a 41   01   IOS Seguradoras (usar 0)				      
	//   42 a 44   03   Carteira 							          
	cRet := "9"+Substr(SEE->EE_CODEMP,1,7)+Substr(SE1->E1_NUMBCO,1,12)+cDigNNum+"0"+Substr(SEE->EE_XCART,1,3)
	Case cCodBanco == '041'// Banrisul
	//  BANRISUL
	//   - POSICOES LIVRES DO BCO (CAMPO LIVRE)                       
	//   20 a 20   01   Produto (1 ou 2)                              
	//   21 a 21   01   Constante "1"                                 
	//   22 a 25   04   Agencia sem Digito                            
	//   26 a 32   07   Cedente sem Nr. Controle			          
	//   33 a 40   08   Nosso Numero sem Nr. Controle                 
	//   41 a 42   01   Cobnstante "40"              	              
	//   43 a 44   02   Duplo Digito*                                 
	cRet := "21"+Substr(MV_PAR02,1,4)+Substr(MV_PAR03,1,7)+Substr(SE1->E1_NUMBCO,1,8)+"40"+cDigNNum
	Otherwise
	cRet := Space(24)
	EndCase

	Return cRet
	*/

	/*/{Protheus.doc} DigMod11 - OBSOLETA [Substituida pela função do padrão Modulo11()]
	//Funcao que gera o Digito Verificador do "Nosso Numero" MOD(11) Pesos (2 a 9)

	@author 	luciano.camargo
	@since 		27/04/2017
	@version 	P11.8
	@param 		cString, characters, descricao
	@param 		nPeso, numeric, descricao
	@param 		nAte, numeric, descricao
	@type 		function

	/*/
/*
Static Function DigMod11(cString,nPeso,nAte)

Local nCont	:= 0
Local cRet 	:= ""
Local nX
Local nResto:= 0
Local nAux	:= nPeso

cString := Alltrim(cString)

For nX:=Len(cString) to 1 Step -1
nCont:=nCont+(Val(SUBSTR(cString,nX,1))*nAux)
nAux:=nAux+10
If nAux>nAte
nAux:=nPeso
Endif
Next nX

nResto:=Mod(nCont,11)

If nResto==10
cRet:='0'
Else
cRet:=Str(nResto,1)
Endif

Return(cRet)
*/

/*/{Protheus.doc} LinhaDgt
//Funcao que monta a linha digitavel do boleto - OBSOLETA [Tratamento no corpo da função principal]

@author 	luciano.camargo
@since 		27/04/2017
@version 	P11.8
@param 		cCodBar, characters, descricao
@type 		function

/*/
/*
Static Function LinhaDgt(cCodBar)

Local cRet		:= ""
Local cDig 		:= ""
Local cAux		:= ""

//Calculo do Primeiro Campo
cRet := Substr(cCodBar,1,4)+Substr(cCodBar,20,5)
cDig := DigMod10(cRet) // Gera o digito

cRet := Substr(cRet,1,5)+"."+Substr(cRet,6,4)+cDig+Space(2)

// Calculo do Segundo Campo
cAux := Substr(cCodBar,25,10)
nDig :=	DigMod10(cAux)
cRet := cRet + Substr(cAux,1,5) +"."+Substr(cAux,6,5) +nDig + Space(2)

// Calculo do Terceiro Campo
cAux := Substr(cCodBar,35,10)
nDig := DigMod10(cAux)
cRet := cRet + Substr(cAux,1,5)+"."+Substr(cAux,6,5) + nDig + Space(2)

// Calculo do Quarto Campo
// Digito Verificador Geral
cRet := cRet +Substr(cCodBar,5,1)+Space(2)

// Calculo do Quinto Campo
cRet := cRet + Substr(cCodBar,6,14)

Return cRet
*/



/*/{Protheus.doc} Ret_cBarra
Função responsável pelo código de barras.
@author marcos.aleluia
@since 07/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cBanco, characters, descricao
@param cAgencia, characters, descricao
@param cConta, characters, descricao
@param cDacCC, characters, descricao
@param cNroDoc, characters, descricao
@param nValor, numeric, descricao
@param dVencto, date, descricao
@type function
/*/
Static Function Ret_cBarra(cBanco, cAgencia, cConta, cDacCC, cNroDoc, nValor, dVencto)

	Local cValorFinal	:= strzero(int(nValor * 0100), 10)
	Local nDvnn			:= 0
	Local nDvcb			:= 0
	Local nDv			:= 0
	Local cNN			:= " "
	Local cRN			:= " "
	Local cCB			:= " "
	Local cNNSD			:= " "
	Local cNNCD			:= " "
	Local cS			:= " "
	Local cFator		:= strzero(dVencto - ctod("07/10/97"), 4)
	Local cCart			:= Alltrim(SEE->EE_XCART)

	//-----------------------------
	// DEFINIÇÃO DO NOSSO NÚMERO
	// ----------------------------
	cS    := cNroDoc 						// CCCCCCCNNNNNNNNNN - C - CONVÊNIO N - NUMERO DO TITULO
	nDvNN := NNUMMOD11(cS, "NN", cCart)	// DÍGITO VERIFICADOR
	cNNSD := cS               				// NOSSO NÚMERO SEM DÍGITO
	//cNN   := Alltrim(Str(cNroDoc))		// PARA CONVÊNIO DE 7 POSIÇÕES, NÃO DEVE-SE MANDAR DÍGITO VERIFICADOR.
	cNNCD := cS + nDvnn               				// NOSSO NÚMERO COM DÍGITO
	cNN   := Alltrim(cNNSD)

	//----------------------------------
	// DEFINIÇÃO DO CÓDIGO DE BARRAS
	//----------------------------------
	cLivre := "000000" + Alltrim(cNNSD) + cCart
	cS     := cBanco + cFator +  cValorFinal + cLivre // + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'
	nDvCB  := NNUMMOD11(cS, "CODBAR", cCart)
	cCB    := SubStr(cS, 1, 4) + nDvcb + SubStr(cS,5)// + SubStr(cS,31)

	//-------- DEFINIÇÃO DA LINHA DIGITAVEL (REPRESENTAÇÃO NÚMERICA)
	//	CAMPO 1		CAMPO 2		CAMPO 3       CAMPO 4   CAMPO 5
	//	AAABC.CCCCX	DDDDD.DDDDDY	FFFFF.FFFFFZ	K         UUUUVVVVVVVVVV

	// 	CAMPO 1:
	//	AAA   = CÓGIDO DO BANCO NA CAMÂRA DE COMPENSAÇÃO
	//	BC     = CÓDIGO DA MOEDA, SEMPRE DEVE SER VALOR 9           		
	//	CCCCC = 5 PRIMEIROS DÍGITOS DO cLivre
	//	X     = DAC QUE AMARRA O CAMPO, CALCULADO PELO MODULO 10 DA STRING DO CAMPO
	cS  := cBanco + Substr(cCB, 20, 5)
	nDv := modulo10(cS)  //DAC
//	cRN := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '
	cRN := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(nDv) + '  '

	// 	CAMPO 2:
	//	DDDDDDDDDD = POSIÇÃO 25 A 34 DO CÓDIGO DE BARRAS 
	//	Y          = DAC QUE AMARRA O CAMPO, CALCULADO PELO MODULO 10 DA STRING DO CAMPO
	cS  := Subs(cCB,25, 10)
	nDv := modulo10(cS)
	cRN += Subs(cS, 1, 5) + '.' + Subs(cS, 6, 5) + Alltrim(nDv) + ' '

	// 	CAMPO 3:
	//	FFFFFFFFFF = POSIÇÃO 16 A 25 DO NOSSO NÚMERO 
	//	Z          = DAC QUE AMARRA O CAMPO, CALCULADO PELO MODULO 10 DA STRING DO CAMPO
	cS  := Subs(cCB, 35, 10)
	nDv := modulo10(cS)
	cRN += Subs(cS, 1, 5) + '.' + Subs(cS, 6, 5) + Alltrim(nDv) + ' '

	//	CAMPO 4:
	// K = DAC DO CÓDIGO DE BARRAS
	cRN += AllTrim(nDvCB) + '  '

	// 	CAMPO 5:
	// UUUU       = FATOR DE VENCIMENTO
	// VVVVVVVVVV = VALOR DO TÍTULO
	cRN += cFator + StrZero(Int(nValor * 0100), 14 - Len(cFator))

Return({cCB, cRN, cNN})




/*/{Protheus.doc} NNUMMOD11
Função responsável pelo cálculo do dígito.
@author marcos.aleluia
@since 08/08/2018
@version 1.0
@return ${return}, ${return_description}
@param nNum, numeric, descricao
@param cTipoCod, characters, descricao
@param cCarteira, characters, descricao
@type function
/*/
Static Function NNUMMOD11(nNum, cTipoCod, cCarteira)

	Local cResult	:= ""
	Local nValor	:= 0
	Local nPos		:= ""
	Local nCont	:= 0
	Local vResto	:= 0
	Local nTotal	:= 0
	
	// CALCULA DIGITO VERIFICADOR DO NOSSO NUMERO.
	if cTipoCod == "NN"
		nPos += Padl(nNum, 11, "0")
		
		For nCont := 1 to Len(nPos)
			Do case
			case nCont == 1
				nValor += (val(subs(nPos, nCont, 1)) * 7)
			case nCont == 2
				nValor += (val(subs(nPos, nCont, 1)) * 8)
			case nCont == 3
				nValor += (val(subs(nPos, nCont, 1)) * 9)
			case nCont == 4
				nValor += (val(subs(nPos, nCont, 1)) * 2)
			case nCont == 5
				nValor += (val(subs(nPos, nCont, 1)) * 3)
			case nCont == 6
				nValor += (val(subs(nPos, nCont, 1)) * 4)
			case nCont == 7
				nValor += (val(subs(nPos, nCont, 1)) * 5)
			case nCont == 8
				nValor += (val(subs(nPos, nCont, 1)) * 6)
			case nCont == 9
				nValor += (val(subs(nPos, nCont, 1)) * 7)
			case nCont == 10
				nValor += (val(subs(nPos, nCont, 1)) * 8)
			case nCont == 11
				nValor += (val(subs(nPos, nCont, 1)) * 9)
			/*
			case nCont == 12
				nValor += (val(subs(nPos, nCont, 1)) * 4)
			case nCont == 13
				nValor += (val(subs(nPos, nCont, 1)) * 5)
			case nCont == 14
				nValor += (val(subs(nPos, nCont, 1)) * 6)
			case nCont == 15
				nValor += (val(subs(nPos, nCont, 1)) * 7)
			case nCont == 16
				nValor += (val(subs(nPos, nCont, 1)) * 8)
			case nCont == 17
				nValor += (val(subs(nPos, nCont, 1)) * 9)
			*/
			EndCase
		Next nCont
		
		vResto := mod(nValor, 11)

		If vResto < 10
			nValor	:= vResto
		ElseIf vResto == 0
			nValor := 0
		ElseIf vResto == 10
			nValor := vResto
		endif

		nValor := Alltrim(Str(nValor, 0))

		If nValor == "10"
			cResult = "X"
		Else
			cResult = nValor
		Endif

	Endif
	
	//CALCULA DIGITO VERIFICADOR DO CODIGO DE BARRAS.
	If cTipoCod == "CODBAR"
		nNum := padl(nNum, 43, "0")
		
		for nCont := 1 to len(nNum)
			Do Case
			case nCont == 1
				nValor := (val(subs(nNum, nCont, 1)) * 4)
			case nCont == 2
				nValor := (val(subs(nNum, nCont, 1)) * 3)
			case nCont == 3
				nValor := (val(subs(nNum, nCont, 1)) * 2)
			case nCont == 4
				nValor := (val(subs(nNum, nCont, 1)) * 9)
			case nCont == 5
				nValor := (val(subs(nNum, nCont, 1)) * 8)
			case nCont == 6
				nValor := (val(subs(nNum, nCont, 1)) * 7)
			case nCont == 7
				nValor := (val(subs(nNum, nCont, 1)) * 6)
			case nCont == 8
				nValor := (val(subs(nNum, nCont, 1)) * 5)
			case nCont == 9
				nValor := (val(subs(nNum, nCont, 1)) * 4)
			case nCont == 10
				nValor := (val(subs(nNum, nCont, 1)) * 3)
			case nCont == 11
				nValor := (val(subs(nNum, nCont, 1)) * 2)
			case nCont == 12
				nValor := (val(subs(nNum, nCont, 1)) * 9)
			case nCont == 13
				nValor := (val(subs(nNum, nCont, 1)) * 8)
			case nCont == 14
				nValor := (val(subs(nNum, nCont, 1)) * 7)
			case nCont == 15
				nValor := (val(subs(nNum, nCont, 1)) * 6)
			case nCont == 16
				nValor := (val(subs(nNum, nCont, 1)) * 5)
			case nCont == 17
				nValor := (val(subs(nNum, nCont, 1)) * 4)
			case nCont == 18
				nValor := (val(subs(nNum, nCont, 1)) * 3)
			case nCont == 19
				nValor := (val(subs(nNum, nCont, 1)) * 2)
			case nCont == 20
				nValor := (val(subs(nNum, nCont, 1)) * 9)
			case nCont == 21
				nValor := (val(subs(nNum, nCont, 1)) * 8)
			case nCont == 22
				nValor := (val(subs(nNum, nCont, 1)) * 7)
			case nCont == 23
				nValor := (val(subs(nNum, nCont, 1)) * 6)
			case nCont == 24
				nValor := (val(subs(nNum, nCont, 1)) * 5)
			case nCont == 25
				nValor := (val(subs(nNum, nCont, 1)) * 4)
			case nCont == 26
				nValor := (val(subs(nNum, nCont, 1)) * 3)
			case nCont == 27
				nValor := (val(subs(nNum, nCont, 1)) * 2)
			case nCont == 28
				nValor := (val(subs(nNum, nCont, 1)) * 9)
			case nCont == 29
				nValor := (val(subs(nNum, nCont, 1)) * 8)
			case nCont == 30
				nValor := (val(subs(nNum, nCont, 1)) * 7)
			case nCont == 31
				nValor := (val(subs(nNum, nCont, 1)) * 6)
			case nCont == 32
				nValor := (val(subs(nNum, nCont, 1)) * 5)
			case nCont == 33
				nValor := (val(subs(nNum, nCont, 1)) * 4)
			case nCont == 34
				nValor := (val(subs(nNum, nCont, 1)) * 3)
			case nCont == 35
				nValor := (val(subs(nNum, nCont, 1)) * 2)
			case nCont == 36
				nValor := (val(subs(nNum, nCont, 1)) * 9)
			case nCont == 37
				nValor := (val(subs(nNum, nCont, 1)) * 8)
			case nCont == 38
				nValor := (val(subs(nNum, nCont, 1)) * 7)
			case nCont == 39
				nValor := (val(subs(nNum, nCont, 1)) * 6)
			case nCont == 40
				nValor := (val(subs(nNum, nCont, 1)) * 5)
			case nCont == 41
				nValor := (val(subs(nNum, nCont, 1)) * 4)
			case nCont == 42
				nValor := (val(subs(nNum, nCont, 1)) * 3)
			case nCont == 43
				nValor := (val(subs(nNum, nCont, 1)) * 2)
			endcase
			
			nTotal += nValor
		next
		
		vResto := mod(nTotal, 11)
		
		nValor := 11 - vResto

		if nValor == 0 .or. nValor > 9
			cResult := 1
		Else
			cResult := nValor
		endif
		
		cResult := Alltrim(Str(cResult, 0))

	Endif

Return(cResult)