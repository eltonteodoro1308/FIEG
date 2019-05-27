#INCLUDE "PROTHEUS.CH"
#Include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} SIFINA11
Rotina de tratamento de mutuo a pagar/receber.

@author  Microsiga
@since   09/04/2012
@version MP 12.1.17
@type	 function
@obs 	 P11 - SISTEMA INDUSTRIA
/*/
//-------------------------------------------------------------------

User Function SIFINA11(_nOpc)

	Local _cArea      := GetArea()
	Local cRotinaNom  := "Rateio do M๚tuo"

	Private _cPrefSE1 := CriaVar("E1_PREFIXO",.T.)
	Private _cTipoSE1 := CriaVar("E1_TIPO")
	Private _cNumSE1  := CriaVar("E1_NUM")
	Private _cNatSE1  := CriaVar("E1_NATUREZ")
	Private _dVencSE1 := dDataBase
	Private _cPrefSE2 := CriaVar("E2_PREFIXO",.T.)
	Private _cTipoSE2 := CriaVar("E2_TIPO")
	Private _cNumSE2  := CriaVar("E2_NUM")
	Private _cNatSE2  := CriaVar("E2_NATUREZ")
	Private _dVencSE2 := dDataBase
	Private _cTpMutuo := Iif( Alias()=="SE2" , "1" , "2") 					// Origem do Mutuo, sendo: 1 = Contas a Pagar, 2 = Contas a Receber
	Private _cOrigem  := Iif( _cTpMutuo=="1" , SE2->E2_XORIGEM , SE1->E1_XORIGEM )
	Private _cMutuo   := Iif( _cTpMutuo=="1" , SE2->E2_XMUTUO  , SE1->E1_XMUTUO  )
	Private _cStatus  := Iif( _cTpMutuo=="1" , SE2->E2_XSTATUS , SE1->E1_XSTATUS )
	Private _lManual  := Iif( _cTpMutuo=="1" , Alltrim(SE2->E2_ORIGEM)=="FINA050" , Alltrim(SE1->E1_ORIGEM)=="FINA040" )
	Private aMotBaixa := ReadMotBx()
	Private cCodMotBx := "DAC"						&& Codigo do Motivo de Baixa utilizado para baixa dos titulos na Casa Centralizadora
	Private lMotExist := Iif( Ascan(aMotBaixa, {|x| Substr(x,1,3) = Upper(cCodMotBx) })>0 , .T. , .F. )
	Private lMotBxMov := MovBcoBx(cCodMotBx)
	Private _cFilOrig := Iif( _cTpMutuo=="1" , SE2->E2_FILIAL , SE1->E1_FILIAL )

	//---< Valida็๕es iniciais antes dos parโmetros da rotina >-------------
	If !Empty(_cOrigem) .and. _cOrigem <> _cTpMutuo
		MsgAlert("Este rateio nใo pertence a outra carteira.","Aten็ใo")
		Return()
	EndIf

	If _cOrigem == "3" 									// agregado
		MsgAlert("Tํtulo amarrado ao rateio "+_cMutuo+". Verifique!","Aten็ใo")
		Return()
	EndIf

	If _nOpc == 1 										// inclusao
		If !Empty(_cMutuo)
			MsgAlert("Jแ existe rateio gerado para este tํtulo.","Aten็ใo")
			Return()
		EndIf
	ELSE
		If Empty(_cMutuo)
			MsgAlert("Nใo existe rateio cadastrado para este tํtulo.","Aten็ใo")
			Return()
		EndIf

		Do Case

			Case _nOpc == 2 							// Altera็ใo

			If _cStatus == "2"
				MsgAlert("Rateio Finalizado.","Aten็ใo")
				Return()
			EndIf

			Case _nOpc == 3 							// Exclusใo

			If _cStatus == "2"
				MsgAlert("Rateio Finalizado! Utilize op็ใo de estorno.","Aten็ใo")
				Return()
			ElseIf MsgYesNo("Confirma exclusใo do Rateio do M๚tuo "+_cMutuo+" ?","Rateio do M๚tuo")
				MsgRun("Excluindo regra de rateio. Aguarde...",cRotinaNom, {|| SIFIN11Del() } )
			EndIf

			Return()

			Case _nOpc == 5 							// Efetiva็ใo

			If _cStatus == "2"
				MsgAlert("Este rateio jแ foi efetivado.","Aten็ใo")
				Return()
			Else
				If !lMotExist
					MsgStop("O Motivo de Baixa c๓digo " +cCodMotBx+ " nใo estแ cadastrado." +CRLF+CRLF+ ;
					"Cadastre o Motivo de Baixa para prosseguir.","Aten็ใo")
					Return()
				ElseIf lMotBxMov
					MsgStop("O Motivo de Baixa c๓digo " +cCodMotBx+ " nใo pode Movimentar Banco." +CRLF+CRLF+ ;
					"Altere o campo 'Mov.Bancแria' para Nใo no cadastro do Motivo de Baixa para prosseguir.","Aten็ใo")
					Return()
				ElseIf SIFIN11Par() .and. MsgYesNo("Confirma efetiva็ใo do Rateio do M๚tuo "+_cMutuo+" ?","Rateio do M๚tuo")
					//MsgRun("Efetivando Rateio. Aguarde...",cRotinaNom, {|| SIFIN11Run() } )
					FWMsgRun(, {|oSay| SIFIN11Run(oSay) }, "Efetivando o Rateio do M๚tuo", "Rateio sendo efetivado. Por favor, aguarde." )
				EndIf
			EndIf

			Return()

			Case _nOpc == 6 							// Estornar Efetiva็ใo

			IF _cStatus <> "2"
				MsgAlert("Este rateio nใo foi efetivado.","Aten็ใo")
				Return()
			ElseIf MsgYesNo("Confirma estornar do Rateio do M๚tuo "+_cMutuo+" ?","Rateio do M๚tuo")
				//MsgRun("Estornado Rateio. Aguarde...",cRotinaNom, {|| SIFIN11Est() } )
				FWMsgRun(, {|oSay| SIFIN11Est(oSay) }, "Estornando o Rateio sendo executado", "Por favor, aguarde o final do processamento" )

			EndIf

			Return()

		EndCase

	EndIf

	SIFIN11Man(_nOpc)

	RestArea(_cArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณSIFIN11Manบ Autor ณ Microsiga          บ Data ณ  09/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Manutencao do Rateio                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 = 1 - Inclusao     								  บฑฑ
ฑฑบ	         ณ         2 - Alteracao        	    					  บฑฑ
ฑฑบ          ณ         3 - Exclusao                						  บฑฑ
ฑฑบ          ณ         4 -                                                บฑฑ
ฑฑบ          ณ         5 - Efetivacao                                     บฑฑ
ฑฑบ          ณ         6 - Estorna Efetivacao                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN11Man(_nOpc)

	Local oDlg
	Local nOpcA      := 0
	Local aButtons   := {}
	Local aNaoSZX    := {"ZX_FILIAL","ZX_RATEIO"}
	Private aNaoSZY  := {"ZY_FILIAL","ZY_RATEIO"}
	Private aHeader  := {}
	Private aCols    := {}
	Private _bRateio := {|| SetKey( VK_F7, NIL ) , SIFIN11Rat( GdFieldGet("ZX_ITEM",oGet:oBrowse:nAt,,oGet:aHeader,oGet:aCols),;
	GdFieldGet("ZX_VALOR",oGet:oBrowse:nAt,,oGet:aHeader,oGet:aCols), _nOpc ),  }
	// backup dos rateios
	Private aBkpCols := {}
	Private aBkpHead := {}
	Private oTotal, oRateio
	Private _nTotal  := 0
	Private _nRateio := 0

	IF _cTpMutuo == "1" // contas a pagar

		// Carrega grupo de perguntas quando acessado via FINA750
		pergunte("FIN050",.F.)

		IF SE2->E2_SALDO == 0
			MsgAlert("Este tํtulo jแ foi totalmente baixado.","Aten็ใo")
			Return()
		ENDIF
		//ANA
		_nTipoRat := mv_par06 // 1 = Bruto; 2 = Liquido
		_nInss    := SE2->E2_INSS

		SED->(dbSetOrder(1))
		IF SED->(dbSeek(XFilial("SED")+SE2->E2_NATUREZ)) .and. SED->(FieldPos("ED_DEDINSS")) > 0
			IF SED->ED_DEDINSS == "2"  //Nao desconta o INSS do principal
				_nInss := 0
			Endif
		ENDIF

		SA2->(dbSetOrder(1))
		SA2->(dbSeek(XFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))

		//Controla o Pis Cofins e Csll na baixa
		lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
		!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
		!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
		!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

		// Controla IRPF na Baixa
		lIRPFBaixa := IIf( ! Empty( SA2->( FieldPos( "A2_CALCIRF" ) ) ), SA2->A2_CALCIRF == "2", .F.) .And. ;
		!Empty( SE2->( FieldPos( "E2_VRETIRF" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETIRF" ) ) ) .And. ;
		!Empty( SE5->( FieldPos( "E5_VRETIRF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETIRF" ) ) )

		lCalcIssBx :=	!Empty( SE5->( FieldPos( "E5_VRETISS" ) ) ) .and. !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .and. ;
		!Empty( SE2->( FieldPos( "E2_TRETISS" ) ) ) .and. GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)

		_nTotal   := Iif(_nTipoRat == 1,SE2->E2_VALOR+If(lIRPFBaixa,0,SE2->E2_IRRF)+If(!lCalcIssBx,SE2->E2_ISS,0)+_nInss+SE2->(E2_RETENC+E2_SEST)+Iif(lPccBaixa,0,SE2->(E2_PIS+E2_COFINS+E2_CSLL)),SE2->E2_VALOR)

	ELSE

		// Carrega grupo de perguntas quando acessado via FINA750
		pergunte("FIN040",.F.)

		IF SE1->E1_SALDO == 0
			MsgAlert("Este tํtulo jแ foi totalmente baixado.","Aten็ใo")
			Return()
		ENDIF

		_nTipoRat := mv_par04 // 1 = Bruto; 2 = Liquido
		IF _nTipoRat == 1 .or. SE1->E1_TIPO $ MVABATIM // Bruto
			_nTotal := SE1->E1_VALOR
		ELSE // Liquido
			_nAbatim  := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			_nTotal := SE1->E1_VALOR - _nAbatim
		ENDIF
	ENDIF

	IF _nOpc == 1 // habilita botao somente na inclusao
		Aadd(aButtons,{'S4WB013N',{|| SIFIN11Atu() },"Regra de Rateio","Carregar Regra"})
	ENDIF

	// Carga inicial do vetor
	IF _nOpc <> 1
		IF Len(aBkpHead) == 0
			cSeek  	  := XFilial("SZY")+_cMutuo
			cWhile 	  := "SZY->(ZY_FILIAL+ZY_RATEIO)"
			FillGetDados(4,"SZY",1,cSeek,{|| &cWhile },{|| .T. },aNaoSZY,/*aSimCpo*/,,,,,aBkpHead,aBkpCols)
			aHeader := {}
			aCols   := {}
		ENDIF
	ENDIF

	// Rateio Contabil
	SetKey( VK_F7, _bRateio )
	Aadd(aButtons,{'S4WB005N',_bRateio,"Rateio Contแbil","Rateio CTB <F7>"})

	cSeek  	  := XFilial("SZX")+_cMutuo
	cWhile 	  := "SZX->(ZX_FILIAL+ZX_RATEIO)"
	FillGetDados(4,"SZX",1,cSeek,{|| &cWhile },{|| .T. },aNaoSZX,/*aSimCpo*/,,,,,aHeader,aCols)

	DEFINE FONT oFnt 	NAME "Arial" SIZE 0, -11 BOLD

	IF Empty(GdFieldGet("ZX_ITEM",1,,aHeader,aCols))
		GDFieldPut("ZX_ITEM",StrZero(1,TamSX3("ZX_ITEM")[1]),1,aHeader,aCols)
	ENDIF

	DEFINE MSDIALOG oDlg FROM 100,100 TO 400,800 TITLE "Regra de Rateio - M๚tuo" Of oMainWnd PIXEL
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,25,25,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_BOTTOM

	nStyle := GD_INSERT+GD_DELETE+GD_UPDATE
	oGet := MsNewGetDados():New(1,1,1,1,nStyle,"U_SIFIN11LOK(1)","AllwaysTrue","+ZX_ITEM", , /*nFreeze*/,9999,,,,oDlg,aHeader,aCols)

	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	// bloqueia quando nao for inclusao ou alteracao
	IF !(_nOpc == 1 .or. _nOpc == 2)
		oGet:OBROWSE:NOPC := 2
	ENDIF

	// Atualiza total do rateio
	aEval( aCols, {|Linha| _nRateio += Linha[GDFieldPos("ZX_VALOR")]  } )

	@ 010,005 SAY OemToAnsi("Total do Documento: ") Of oPanel PIXEL	FONT oFnt
	@ 008,065 MSGET oTotal 	VAR _nTotal Picture X3Picture(Iif(_cTpMutuo=="1","E2_VLCRUZ","E1_VLCRUZ")) Of oPanel READONLY SIZE 60,10 PIXEL
	//Edu
	@ 010,150 SAY OemToAnsi("Total do Rateio: ") Of oPanel PIXEL	FONT oFnt
	@ 008,200 MSGET oRateio 	VAR Round(_nRateio,2) Picture X3Picture(Iif(_cTpMutuo=="1","E2_VLCRUZ","E1_VLCRUZ")) Of oPanel READONLY SIZE 60,10 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| Iif(oGet:TudoOk() .and. SIFIN11TOK(1,_nOpc),(nOpcA:=1,oDlg:End()),(nOpcA:=0))},{||oDlg:End()},,aButtons)

	SetKey( VK_F7, NIL )

	IF nOpcA == 1 .and. (_nOpc == 1 .or. _nOpc == 2) // confirmou

		// Backup do TTS
		lSavTTsInUse := __TTSInUse

		// Ativa TTS
		__TTSInUse := .T.

		// Atualiza rateios antes da gravacao
		For i := 1 to Len(aBkpCols)

			IF GdDeleted(i,aBkpHead,aBkpCols) .or. Empty(_cItemRT := GdFieldGet("ZY_ITEMRAT",i,,aBkpHead,aBkpCols))
				Loop
			ENDIF

			_nValor := oGet:aCols[Ascan(oGet:aCols,{|x| x[ GDFieldPos("ZX_ITEM",oGet:aHeader) ] == _cItemRT }),GDFieldPos("ZX_VALOR",oGet:aHeader)]

			GDFieldPut("ZY_VALOR", _nValor * ( GdFieldGet("ZY_PERCEN",i,,aBkpHead,aBkpCols)/100 ) ,i,aBkpHead,aBkpCols)

		Next

		Begin Transaction

			IF _nOpc == 1 // inclusao

				_cNumRat := U_SIFIN11Num()

				// Gravacao dos dados do Mutuo - Regra
				For i := 1 to Len(oGet:aCols)

					IF GdDeleted(i,oGet:aHeader,oGet:aCols)
						Loop
					ENDIF

					RecLock("SZX",.t.)
					SZX->ZX_FILIAL  := XFilial("SZX")
					SZX->ZX_RATEIO  := _cNumRat
					For x := 1 to Len(oGet:aHeader)
						If ( oGet:aHeader[x,10] <> "V" )
							SZX->(FieldPut(FieldPos(oGet:aHeader[x,2]),oGet:aCols[i,x]))
						EndIf
					Next

					SZX->(msUnlock())
				Next

				// Gravacao do rateio CTB
				For i := 1 to Len(aBkpCols)

					IF GdDeleted(i,aBkpHead,aBkpCols)
						Loop
					ENDIF

					RecLock("SZY",.t.)
					SZY->ZY_FILIAL  := XFilial("SZY")
					SZY->ZY_RATEIO  := _cNumRat
					For x := 1 to Len(aBkpHead)
						IF ( aBkpHead[x,10] <> "V" )
							SZY->(FieldPut(FieldPos(aBkpHead[x,2]),aBkpCols[i,x]))
						EndIf
					Next
					SZY->(msUnlock())
				Next

				// Atualiza campos do tํtulo
				IF _cTpMutuo == "1"
					RecLock("SE2",.f.)
					SE2->E2_XMUTUO  := _cNumRat
					SE2->E2_XSTATUS := "1"
					SE2->E2_XORIGEM := _cTpMutuo
					SE2->(msUnlock())
				ELSE
					RecLock("SE1",.f.)
					SE1->E1_XMUTUO  := _cNumRat
					SE1->E1_XSTATUS := "1"
					SE1->E1_XORIGEM := _cTpMutuo
					SE1->(msUnlock())
				ENDIF

			ELSE // alteracao

				// Gravacao dos dados do Mutuo - Rateio
				For i := 1 to Len(oGet:aCols)

					SZX->(dbSetOrder(1))
					IF !SZX->(dbSeek(XFilial("SZX")+_cMutuo+GdFieldGet("ZX_ITEM",i,,oGet:aHeader,oGet:aCols)))
						IF GdDeleted(i,oGet:aHeader,oGet:aCols)
							Loop
						ENDIF
						RecLock("SZX",.t.)
						SZX->ZX_FILIAL := XFilial("SZX")
						SZX->ZX_RATEIO := _cMutuo
					ELSE
						RecLock("SZX",.f.)
						IF GdDeleted(i,oGet:aHeader,oGet:aCols)
							SZX->(dbDelete())
							SZX->(msUnlock())
							Loop
						ENDIF
					ENDIF

					For x := 1 to Len(oGet:aHeader)
						If ( oGet:aHeader[x,10] <> "V" )
							SZX->(FieldPut(FieldPos(oGet:aHeader[x,2]),oGet:aCols[i,x]))
						EndIf
					Next

					SZX->(msUnlock())
				Next

				// Gravacao do Rateio CTB
				For i := 1 to Len(aBkpCols)

					_cItemRT := GdFieldGet("ZY_ITEMRAT",i,,aBkpHead,aBkpCols)
					_cItemCC := GdFieldGet("ZY_ITEM",i,,aBkpHead,aBkpCols)

					Eval( {|| SZX->(dbSetOrder(1)) , _lDeleta := !SZX->(dbSeek(XFilial("SZX")+_cMutuo+_cItemRT)) } )

					SZY->(dbSetOrder(1))
					IF !SZY->(dbSeek(XFilial("SZY")+_cMutuo+_cItemRT+_cItemCC))
						IF GdDeleted(i,aBkpHead,aBkpCols) .or. _lDeleta
							Loop
						ENDIF
						RecLock("SZY",.t.)
						SZY->ZY_FILIAL := XFilial("SZY")
						SZY->ZY_RATEIO := _cMutuo
					ELSE
						RecLock("SZY",.f.)
						IF GdDeleted(i,aBkpHead,aBkpCols) .or. _lDeleta
							SZY->(dbDelete())
							SZY->(msUnlock())
							Loop
						ENDIF
					ENDIF

					For x := 1 to Len(aBkpHead)
						If ( aBkpHead[x,10] <> "V" )
							SZY->(FieldPut(FieldPos(aBkpHead[x,2]),aBkpCols[i,x]))
						EndIf
					Next

					SZY->(msUnlock())
				Next

			ENDIF

		End Transaction

		// Restaura TTS
		__TTSInUse := lSavTTsInUse

	ENDIF

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11AtuบAutor  ณMicrosiga           บ Data ณ  09/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza regra de rateio conforme orcamento                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN11Atu(_cCC,_cITCTB,_cCLVL,_cConta)

	IF _cTpMutuo=="1" // Pagar
		_cCC	:= SE2->E2_CCD
		_cITCTB	:= SE2->E2_ITEMD
		_cCLVL	:= SE2->E2_CLVLDB
		_cConta	:= SE2->E2_CONTAD
	ELSE // Receber
		_cCC	:= SE1->E1_CCC
		_cITCTB	:= SE1->E1_ITEMC
		_cCLVL	:= SE1->E1_CLVLCR
		_cConta	:= SE1->E1_CREDIT
	ENDIF

	IF Len( _aRegra := U_SIPCO07Orc(_cCC,_cITCTB,_cCLVL,_cConta) ) == 0
		MsgAlert("Nใo existe regra cadastrada para as entidades contแbeis deste tํtulo.","Aten็ใo")
		Return()
	ENDIF

	IF Aviso("Confirma็ใo","Confirma importa็ใo da regra de rateio ?",{"Sim","Nใo"}) <> 1
		Return()
	ENDIF

	For i := 1 to Len(_aRegra)
		//IF _aRegra[i,1] <> cFilAnt // Desconsidera a empresa corrente
		IF GdDeleted(Len(aCols),aHeader,aCols) .or. !Empty(GdFieldGet("ZX_CODEMP",Len(aCols),,aHeader,aCols))
			aAdd(aCols,Array(Len(aHeader)+1))
			For nX := 1 To Len(aHeader)
				IF !(Alltrim(aHeader[nX][2]) $ "ZX_REC_WT|ZX_ALI_WT" )
					aCols[Len(aCols),nX] := CriaVar(aHeader[nX,2])
				ENDIF
			Next nX
			aCols[Len(aCols),Len(aHeader)+1] := .F.
			aCols[Len(aCols),1]  := StrZero(Len(aCols),TamSX3("ZX_ITEM")[1])
		ENDIF

		GDFieldPut("ZX_CODEMP",_aRegra[i,1],Len(aCols),aHeader,aCols)
		GDFieldPut("ZX_PERC",_aRegra[i,2],Len(aCols),aHeader,aCols)

		// Executa gatilhos nos percentual
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("ZX_PERC"))
		IF ExistTrigger("ZX_PERC")
			M->ZX_PERC := _aRegra[i,2]
			RunTrigger(2,Len(aCols))
		ENDIF

		// Executa gatilho da empresa
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("ZX_CODEMP"))
		IF ExistTrigger("ZX_CODEMP")
			RunTrigger(2,Len(aCols))
		ENDIF

		_nRateio += NoRound(GDFieldGet("ZX_VALOR",Len(aCols),,aHeader,aCols),2)

		//ENDIF
	Next

	_nRateio := Round(_nRateio,2)

	oGet:aCols := aClone(aCols)
	oGet:oBrowse:Refresh()
	oRateio:Refresh()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11TOKบAutor  ณMicrosiga           บ Data ณ  09/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da Getdados                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN11TOK(_nOrig,_nOpc)
	Local _lRet := .t.
	Local _nTotRat := 0

	// Se nao for inclusao ou altera็ใo nao faz as consistencias
	IF !( _nOpc == 1 .or. _nOpc == 2 )
		Return .t.
	ENDIF

	IF _nOrig == 1 // Mutuo

		// Consiste ultima linha
		IF !U_SIFIN11LOK(1)
			Return .f.
		ENDIF

		For i := 1 to Len(oGet:aCols)
			IF !GdDeleted(i,oGet:aHeader,oGet:aCols)
				_nTotRat += GdFieldGet("ZX_VALOR",i,,oGet:aHeader,oGet:aCols)
			ENDIF
		Next

		IF _nTotRat <> _nTotal
			MsgStop("O total do rateio nใo deve ser menor/maior que o total do documento.")
			_lRet := .F.
		ENDIF

		IF _nTotRat == 0
			MsgStop("O total do rateio deve ser maior que zero.")
			_lRet := .F.
		ENDIF

		IF _lRet
			IF Aviso("Confirma็ใo","Confirma "+Iif(_nOpc==1,"inclusใo","altera็ใo")+" da regra de rateio ?",{"Sim","Nใo"}) <> 1
				_lRet := .F.
			ENDIF
		ENDIF

	ELSE // Rateio CC

		For i := 1 to Len(oRat:aCols)
			IF !GdDeleted(i,oRat:aHeader,oRat:aCols)
				_nTotRat += GdFieldGet("ZY_VALOR",i,,oRat:aHeader,oRat:aCols)
			ENDIF
		Next

		IF _nTotRat > _nVrCC
			MsgStop("O total do rateio deve ser menor que o total do valor a ser rateado.")
			_lRet := .F.
		ENDIF

		IF _nTotRat <> 0 .and. _nTotRat < _nVrCC
			MsgStop("Existe o saldo de "+Alltrim(Transform(_nVrCC-_nTotRat,"@E 999,999,999.99"))+" para ser rateado.")
			_lRet := .F.
		ENDIF

		IF _lRet
			IF Aviso("Confirma็ใo","Confirma atualiza็ใo de rateio contแbil ?",{"Sim","Nใo"}) <> 1
				_lRet := .F.
			ELSE

				_nPosItem := GdFieldPos("ZY_ITEMRAT",oRat:aHeader)
				_aVetCols := aClone(aBkpCols)
				aBkpCols  := {}

				// Refaz o acols1 sem os deletados e sem o item posicionado
				For i := 1 to Len(_aVetCols)
					IF _aVetCols[i,_nPosItem] <> GdFieldGet("ZY_ITEMRAT",oRat:oBrowse:nAt,,oRat:aHeader,oRat:aCols)
						Aadd(aBkpCols,_aVetCols[i])
					ENDIF
				Next

				// Inclui o item posicionado
				For i := 1 to Len(oRat:aCols)
					IF GdFieldGet("ZY_PERCEN",i,,oRat:aHeader,oRat:aCols) > 0
						Aadd(aBkpCols,oRat:aCols[i])
					ENDIF
				Next

			ENDIF
		ENDIF

	ENDIF

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11RunบAutor  ณMicrosiga           บ Data ณ  04/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetivacao do Rateio - Geracao dos titulos                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN11Run(oSay)

	Local _cArea    := GetArea()
	Local _cParcela := "1"

	Local lSavTTsInUse := __TTSInUse					// Backup do TTS

	__TTSInUse := .T.									// Ativa TTS

	SZX->( dbSetOrder(1), dbSeek(xFilial("SZX")+_cMutuo) )

	Begin Transaction

		While SZX->(!Eof()) .and. SZX->ZX_FILIAL ==xFilial("SZX") .and. SZX->ZX_RATEIO == _cMutuo

			SIFIN11Tit( "R" , _cParcela     , oSay)		// Gera tํtulo a Receber

			SIFIN11Tit( "P" , _cParcela , oSay)		// Gera tํtulo a Pagar

			_cParcela := Soma1(_cParcela)

			SZX->(dbSkip())

		Enddo

		IF _cTpMutuo == "1"								// A Pagar
			RecLock("SE2",.F.)
			SE2->E2_XSTATUS := "2"
			SE2->(msUnlock())
		ELSE											// A Receber
			RecLock("SE1",.F.)
			SE1->E1_XSTATUS := "2"
			SE1->(msUnlock())
		ENDIF

	End Transaction

	__TTSInUse := lSavTTsInUse							// Restaura TTS

	RestArea(_cArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11EstบAutor  ณMicrosiga           บ Data ณ  04/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Estorno da Efetivacao do Rateio                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN11Est(oSay)
	Local aArea := {GetArea(), SE1->(GetArea()), SE2->(GetArea()), SZX->(GetArea())}
	Local lRet := .T.
	Local cQuery := ""
	Local cTab := ""
	Local cFilBkp := cFilAnt
	Local aStru := {}

	Private lMsErroAuto := .F.

	lSavTTSInUse := __TTSInUse

	__TTSInUse := .T.

	Begin Transaction

		//SZX->(dbSetOrder(1))
		//SZX->(dbSeek(XFilial("SZX")+_cMutuo))

		If (_cTpMutuo == "1")
			RecLock("SE2", .F.)
			SE2->(E2_XSTATUS) := "1"
			SE2->(MsUnlock())
		Else
			RecLock("SE1", .F.)
			SE1->(E1_XSTATUS) := "1"
			SE1->(MsUnlock())
		Endif

		cQuery := "SELECT" + CRLF
		cQuery += "'SE1' AS CART," + CRLF
		cQuery += "E1_FILIAL AS FILIAL," + CRLF
		cQuery += "R_E_C_N_O_ AS NUMREG" + CRLF
		cQuery += "FROM " + RetSQLName("SE1") + "" + CRLF
		cQuery += "WHERE E1_XMUTUO = '" + _cMutuo + "'" + CRLF
		cQuery += "AND E1_XORIGEM = '3'" + CRLF
		cQuery += "AND D_E_L_E_T_ = ''" + CRLF
		cQuery += "UNION" + CRLF
		cQuery += "SELECT" + CRLF
		cQuery += "'SE2' AS CART," + CRLF
		cQuery += "E2_FILIAL AS FILIAL," + CRLF
		cQuery += "R_E_C_N_O_ AS NUMREG" + CRLF
		cQuery += "FROM " + RetSQLName("SE2") + "" + CRLF
		cQuery += "WHERE E2_XMUTUO = '" + _cMutuo + "'" + CRLF
		cQuery += "AND E2_XORIGEM = '3'" + CRLF
		cQuery += "AND D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)

		cTab := GetNextAlias()

		TcQuery cQuery NEW ALIAS ((cTab))

		DbSelectArea((cTab))
		(cTab)->(DbGoTop())

		While ((cTab)->(!Eof()))
			lMsErroAuto := .F.
			aStru := {}
			cFilAnt := (cTab)->(FILIAL)

			If ((cTab)->(CART) == "SE1")
				SE1->(DbGoTo((cTab)->(NUMREG)))

				aAdd(aStru, {"E1_FILIAL",  SE1->E1_FILIAL,  Nil})
				aAdd(aStru, {"E1_PREFIXO", SE1->E1_PREFIXO, Nil})
				aAdd(aStru, {"E1_NUM",     SE1->E1_NUM,     Nil})
				aAdd(aStru, {"E1_PARCELA", SE1->E1_PARCELA, Nil})
				aAdd(aStru, {"E1_TIPO",    SE1->E1_TIPO,    Nil})

				If (!Empty(SE1->(E1_BAIXA)))
					oSay:cCaption := ( "Estornando da Baixa a Receber (Pref/N๚m/Parc/Tp): " + RTrim(SE1->E1_PREFIXO) + "/" + RTrim(SE1->E1_NUM) + "/" + RTrim(SE1->E1_PARCELA) + "/" + RTrim(SE1->E1_TIPO) )
					ProcessMessages()
					MsExecAuto({|x,y| FINA070(x,y)}, aStru, 6)
				Endif

				oSay:cCaption := ( "Excluindo Tํtulo เ Receber (Pref/N๚m/Parc/Tp): " + RTrim(SE1->E1_PREFIXO) + "/" + RTrim(SE1->E1_NUM)  + "/"  + RTrim(SE1->E1_PARCELA) + "/" + RTrim(SE1->E1_TIPO) )
				ProcessMessages()
				MsExecAuto({|x,y| FINA040(x,y)}, aStru, 5)
			Else
				SE2->(DbGoTo((cTab)->(NUMREG)))

				aAdd(aStru, {"E2_FILIAL",  SE2->E2_FILIAL,  Nil})
				aAdd(aStru, {"E2_PREFIXO", SE2->E2_PREFIXO, Nil})
				aAdd(aStru, {"E2_NUM",     SE2->E2_NUM,     Nil})
				aAdd(aStru, {"E2_PARCELA", SE2->E2_PARCELA, Nil})
				aAdd(aStru, {"E2_TIPO",    SE2->E2_TIPO,    Nil})
				aAdd(aStru, {"E2_FORNECE", SE2->E2_FORNECE, Nil})
				aAdd(aStru, {"E2_LOJA",    SE2->E2_LOJA,    Nil})

				DbSelectArea("SE2")
				SE2->(DbSetOrder(1))
				SE2->(DbSeek(aStru[1, 2] + aStru[2, 2] + aStru[3, 2] + aStru[4, 2] + aStru[5, 2] + aStru[6, 2] + aStru[7, 2]))

				If (!Empty(SE2->(E2_BAIXA)))
					oSay:cCaption := ( "Estornando da Baixa a Pagar (Pref/N๚m/Parc/Tp): " + RTrim(SE2->E2_PREFIXO) + "/" + RTrim(SE2->E2_NUM) + "/" + RTrim(SE2->E2_PARCELA) + "/" + RTrim(SE2->E2_TIPO) )
					ProcessMessages()
					MsExecAuto({|x,y,z| FINA080(x,y,z)}, aStru, 5)
				Endif

				oSay:cCaption := ( "Excluindo Tํtulo a Pagar: (Pref/N๚m/Parc/Tp): " + RTrim(SE2->E2_PREFIXO) + "/" + RTrim(SE2->E2_NUM) + "/" + RTrim(SE2->E2_PARCELA) + "/" + RTrim(SE2->E2_TIPO) )
				MsExecAuto({|x,y,z| FINA050(x,y,z)}, aStru, , 5)

				//SZX->(DbSkip())
			Endif

			If (lMsErroAuto)
				If (__lSX8)
					RollBackSX8()
				Endif

				DisarmTransaction()

				MostraErro()

				cFilAnt := cFilBkp

				Break
			Else
				If (__lSX8)
					ConfirmSX8()
				Endif
			Endif

			(cTab)->(DbSkip())
		Enddo

		(cTab)->(DbCloseArea())

	End Transaction

	__TSSInUse := lSavTTSInUse

	cFilAnt := cFilBkp

	aEval(aArea, {|x| RestArea(x)})
Return(lRet)

/*Static Function SIFIN11Est()
Local _cArea   := GetArea()
Local _cQuery  := ""
Local _cArqTRB := CriaTrab(nil,.f.)

_cQuery := "SELECT 'SE1' CART, E1_FILIAL FILIAL,R_E_C_N_O_ NUMREG FROM "+RetSqlName("SE1")+" WHERE D_E_L_E_T_ = ' ' AND E1_XMUTUO = '"+_cMutuo+"' "
_cQuery += "AND E1_XORIGEM = '3'" // considera somente titulos agregados
_cQuery += " UNION "
_cQuery += "SELECT 'SE2' CART, E2_FILIAL FILIAL,R_E_C_N_O_ NUMREG FROM "+RetSqlName("SE2")+" WHERE D_E_L_E_T_ = ' ' AND E2_XMUTUO = '"+_cMutuo+"' "
_cQuery += "AND E2_XORIGEM = '3'" // considera somente titulos agregados
_cQuery := ChangeQuery(_cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTRB,.t.,.t.)

cFilBak  := cFilAnt // guarda filial corrente

// Backup do TTS
lSavTTsInUse := __TTSInUse

// Ativa TTS
__TTSInUse := .T.

Begin Transaction

IF _cTpMutuo == "1"
RecLock("SE2",.F.)
SE2->E2_XSTATUS := "1" // volta para status de Em Aberto
SE2->(msUnlock())
ELSE
RecLock("SE1",.F.)
SE1->E1_XSTATUS := "1" // volta para status de Em Aberto
SE1->(msUnlock())
ENDIF

While (_cArqTRB)->(!Eof())

lMsErroAuto := .f.
aStru       := {}
cFilAnt     := (_cArqTRB)->FILIAL

IF (_cArqTRB)->CART == "SE1" // titulos a receber

SE1->(dbGoTo((_cArqTRB)->NUMREG))

aAdd( aStru, { 'E1_FILIAL ', SE1->E1_FILIAL  , NIL } )
aAdd( aStru, { 'E1_PREFIXO', SE1->E1_PREFIXO , NIL } )
aAdd( aStru, { 'E1_NUM    ', SE1->E1_NUM	 , NIL } )
aAdd( aStru, { 'E1_PARCELA', SE1->E1_PARCELA , NIL } )
aAdd( aStru, { 'E1_TIPO   ', SE1->E1_TIPO    , NIL } )

If !Empty(SE1->E1_BAIXA)	// Estorna a Baixa do Contas a Receber
MSExecAuto({|x, y | FINA070(x, y )}, aStru, 6 )
EndIf

MSExecAuto( { | x, y | Fina040( x, y ) }, aStru, 5 )

ELSE // titulos a pagar

SE2->(dbGoTo((_cArqTRB)->NUMREG))

aAdd( aStru, { 'E2_FILIAL ', SE2->E2_FILIAL  , NIL } )
aAdd( aStru, { 'E2_PREFIXO', SE2->E2_PREFIXO , NIL } )
aAdd( aStru, { 'E2_NUM    ', SE2->E2_NUM	 , NIL } )
aAdd( aStru, { 'E2_PARCELA', SE2->E2_PARCELA , NIL } )
aAdd( aStru, { 'E2_TIPO   ', SE2->E2_TIPO    , NIL } )
aAdd( aStru, { 'E2_NATUREZ', SE2->E2_NATUREZ , NIL } )
aAdd( aStru, { 'E2_FORNECE', SE2->E2_FORNECE , NIL } )
aAdd( aStru, { 'E2_LOJA   ', SE2->E2_LOJA    , NIL } )
aAdd( aStru, { 'E2_MOEDA  ', SE2->E2_MOEDA   , NIL } )

If !Empty(SE2->E2_BAIXA)	// Estorna a Baixa do Contas a Pagar
MSExecAuto({|x,y,z| FINA080(x,y,z)},aStru,5)
EndIf

SE2->(dbGoTo((_cArqTRB)->NUMREG))

MsExecAuto({|x,y,z| FINA050(x,y,z)}, aStru, , 5)

ENDIF

If lMsErroAuto
If (__lSX8)
RollBackSX8()
EndIf

DisarmTransaction()

MostraErro()

cFilAnt := cFilBak

Break
Else
If (__lSX8)
ConfirmSX8()
EndIf
EndIf

(_cArqTRB)->(dbSkip())
Enddo

End Transaction

// Restaura TTS
__TTSInUse := lSavTTsInUse

(_cArqTRB)->(dbCloseArea())
FErase(_cArqTRB+GetDBExtension())
FErase(_cArqTRB+OrdBagExt())
cFilAnt := cFilBak
RestArea(_cArea)
Return()*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11DelบAutor  ณMicrosiga           บ Data ณ  04/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Manutencao de rateio de mutuo                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN11Del()
	Local _cArea := GetArea()

	SZX->(dbSetOrder(1))
	SZX->(dbSeek(XFilial("SZX")+_cMutuo))

	While SZX->(!Eof()) .and. SZX->ZX_FILIAL == XFilial("SZX") .and. SZX->ZX_RATEIO == _cMutuo

		// Exclui registros da tabela de mutuo
		RecLock("SZX",.F.)
		SZX->(dbDelete())
		SZX->(msUnlock())

		SZX->(dbSkip())
	Enddo

	SZY->(dbSetOrder(1))
	SZY->(dbSeek(XFilial("SZY")+_cMutuo))

	While SZY->(!Eof()) .and. SZY->ZY_FILIAL == XFilial("SZY") .and. SZY->ZY_RATEIO == _cMutuo

		// Exclui registros do rateio contabil
		RecLock("SZY",.F.)
		SZY->(dbDelete())
		SZY->(msUnlock())

		SZY->(dbSkip())
	Enddo

	// Atualiza tabela de tํtulos
	IF _cTpMutuo == "1"
		RecLock("SE2",.F.)
		SE2->E2_XMUTUO  := ""
		SE2->E2_XSTATUS := ""
		SE2->E2_XORIGEM := ""
		SE2->(msUnlock())
	ELSE
		RecLock("SE1",.F.)
		SE1->E1_XMUTUO  := ""
		SE1->E1_XSTATUS := ""
		SE1->E1_XORIGEM := ""
		SE1->(msUnlock())
	ENDIF

	RestArea(_cArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11LOKบAutor  ณMicrosiga           บ Data ณ  04/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao de linha                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SIFIN11LOK(_nOrig)
	Local _lRet := .t.


	IF _nOrig == 1 // Mutuo

		IF GDDeleted(oGet:oBrowse:nAt,oGet:aHeader,oGet:aCols)
			Return .t.
		ENDIF

		IF Ascan(aCols,{|x| !x[Len(aHeader)+1] .and. x[GDFieldPos("ZX_CODEMP",oGet:aHeader)] == GDFieldGet("ZX_CODEMP",oGet:oBrowse:nAt,,oGet:aHeader,oGet:aCols) .and. x[GDFieldPos("ZX_ITEM",oGet:aHeader)] <> GDFieldGet("ZX_ITEM",oGet:oBrowse:nAt,,oGet:aHeader,oGet:aCols) }) > 0
			MsgInfo("A empresa "+GDFieldGet("ZX_CODEMP",oGet:oBrowse:nAt,,oGet:aHeader,oGet:aCols)+" jแ foi informada!")
			_lRet := .f.
		ENDIF

		IF _lRet
			_nRateio := 0 //25009.36

			For i := 1 to Len(oGet:aCols)
				IF !GDDeleted(i,oGet:aHeader,oGet:aCols)
					_nRateio += GDFieldGet("ZX_VALOR",i,,oGet:aHeader,oGet:aCols) //Edu
				ENDIF
			Next

			_nRateio := Round(_nRateio,2) //Edu

			oRateio:Refresh()
		ENDIF

	ELSE // Rateio CC

		IF GDDeleted(oRat:oBrowse:nAt,oRat:aHeader,oRat:aCols)
			Return .t.
		ENDIF

		_nRatCC := 0

		For i := 1 to Len(oRat:aCols)
			IF !GDDeleted(i,oRat:aHeader,oRat:aCols)
				_nRatCC += NoRound(GDFieldGet("ZY_VALOR",i,,oRat:aHeader,oRat:aCols),2)
			ENDIF
		Next

		oRatCC:Refresh()
	ENDIF

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11NumบAutor  ณMicrosiga           บ Data ณ  04/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula numero do rateio                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SIFIN11Num()
	//Local _cRet    := StrZero(1,TamSX3("ZX_RATEIO")[1])
	Local _cRet    := StrZero(1,TamSX3("E2_XMUTUO")[1])
	Local _cQuery  := ""
	Local _cArqTRB := CriaTrab(nil,.f.)
	Local _cArea   := GetArea()

	//_cQuery := "SELECT MAX(ZX_RATEIO) RATEIO FROM "+RetSqlName("SZX")+" WHERE D_E_L_E_T_ = ' ' AND ZX_FILIAL = '"+XFilial("SZX")+"'"
	_cQuery := "SELECT MAX(E2_XMUTUO) RATEIO FROM "+RetSqlName("SE2")+" WHERE D_E_L_E_T_ = ' '
	_cQuery := ChangeQuery(_cQuery)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTRB,.t.,.t.)

	IF (_cArqTRB)->(!Eof())
		_cRet := Soma1((_cArqTRB)->RATEIO)
	ENDIF

	(_cArqTRB)->(dbCloseArea())
	FErase(_cArqTRB+GetDBExtension())
	FErase(_cArqTRB+OrdBagExt())
	RestArea(_cArea)
Return(_cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11ParบAutor  ณMicrosiga           บ Data ณ  04/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Captura parametros para geracao dos titulos                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN11Par()
	Local oDlg
	Local _lRet     := .f.
	Local _nOpca    := 0
	Local nOk		:= 0
	Local _bValid   := {|| Iif( Empty(_cTipoSE1).or.Empty(_cNumSE1).or.Empty(_cNatSE1).or.;
	Empty(_cTipoSE2).or.Empty(_cNumSE2).or.Empty(_cNatSE2),nOk := 2,;
	Iif(Posicione("SED",1,xFilial("SED")+_cNatSE1,"ED_MOVBCO")=="1" .or. ;
	Posicione("SED",1,xFilial("SED")+_cNatSE2,"ED_MOVBCO")=="1", nOk := 3, nOk := 1) ) }
	Local cOkMsg2	:= "Campos obrigat๓rios nใo informados!"
	Local cOkMsg3	:= "Informe uma Natureza que Nใo Movimenta Banco."

	_cPrefSE1 := PadR( GetMv("SI_PRFREC"), GetSx3Cache( 'E1_PREFIXO', 'X3_TAMANHO' ) )
	_cPrefSE2 := PadR( GetMv("SI_PRFPAG"), GetSx3Cache( 'E1_TIPO'   , 'X3_TAMANHO' ) )
	_cTipoSE1 := PadR( GetMv("SI_TPREC") , GetSx3Cache( 'E2_PREFIXO', 'X3_TAMANHO' ) )
	_cTipoSE2 := PadR( GetMv("SI_TPPAG") , GetSx3Cache( 'E2_TIPO', 'X3_TAMANHO' ) )
	_cNumSE1  := SE2->(E2_NUM)
	_cNumSE2  := SE2->(E2_NUM)
	_cNatSE1  := SubStr(GetMv("SI_NATREC")+Space(TamSx3("E1_NATUREZ")[1]),1,TamSx3("E1_NATUREZ")[1])
	_cNatSE2  := SubStr(GetMv("SI_NATPAG")+Space(TamSx3("E2_NATUREZ")[1]),1,TamSx3("E2_NATUREZ")[1])
	_dVencSE1 := dDataBase
	_dVencSE2 := dDataBase

	DEFINE MSDIALOG oDlg FROM 22,9 TO 180,540 TITLE OemToAnsi("Configura็ใo dos Tํtulos") PIXEL
	oDlg:lMaximized := .F.
	oPanel := TPanel():New(0,0,'',oDlg,,.T.,.T.,,,20,20,.F.,.F.)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 003,005 TO 038, 223 LABEL "Titulo(s) a Receber" OF oPanel PIXEL
	@ 040,005 TO 075, 223 LABEL "Titulo(s) a Pagar"   OF oPanel PIXEL

	// Contas a Receber
	@ 012, 015 SAY OemToAnsi("Prefixo")		SIZE 20, 7 OF oPanel PIXEL
	@ 012, 051 SAY OemToAnsi("Tp") 			SIZE 12, 7 OF oPanel PIXEL
	@ 012, 081 SAY OemToAnsi("Nr. Tํtulo") 	SIZE 49, 7 OF oPanel PIXEL
	@ 012, 126 SAY OemToAnsi("Natureza") 	SIZE 25, 7 OF oPanel PIXEL
	@ 012, 181 SAY OemToAnsi("Vencimento") 	SIZE 50, 7 OF oPanel PIXEL

	@ 022, 015 MSGET oPrefSE1 VAR _cPrefSE1 F3 "Z1" Valid ExistCpo("SX5","Z1"+_cPrefSE1) Picture "@!"  SIZE 10, 11 OF oPanel PIXEL HASBUTTON
	@ 022, 051 MSGET oTpSE1   VAR _cTipoSE1	F3 "05" Valid ExistCpo("SX5","05"+_cTipoSE1) Picture "@!"  SIZE 10, 11 OF oPanel PIXEL HASBUTTON
	@ 022, 081 MSGET oTitSE1  VAR _cNumSE1	SIZE 42, 11 OF oPanel PIXEL
	@ 022, 126 MSGET oNatSE1  VAR _cNatSE1	F3 "SED" Valid ExistCPO("SED",_cNatSE1) SIZE 55, 11 OF oPanel PIXEL HASBUTTON
	@ 022, 181 MSGET oVencSE1 VAR _dVencSE1	VALID _dVencSE1 >= dDataBase SIZE 42, 11 OF oPanel PIXEL HASBUTTON

	// Contas a Pagar
	@ 047, 015 SAY OemToAnsi("Prefixo")		SIZE 20, 7 OF oPanel PIXEL
	@ 047, 051 SAY OemToAnsi("Tp") 			SIZE 12, 7 OF oPanel PIXEL
	@ 047, 081 SAY OemToAnsi("Nr. Tํtulo") 	SIZE 49, 7 OF oPanel PIXEL
	@ 047, 126 SAY OemToAnsi("Natureza") 	SIZE 25, 7 OF oPanel PIXEL
	@ 047, 181 SAY OemToAnsi("Vencimento") 	SIZE 50, 7 OF oPanel PIXEL

	@ 057, 015 MSGET oPrefSE2 VAR _cPrefSE2 F3 'Z1' Valid ExistCpo("SX5","Z1"+_cPrefSE2) Picture "@!"  SIZE 10, 11 OF oPanel PIXEL HASBUTTON
	@ 057, 051 MSGET oTpSE2   VAR _cTipoSE2	F3 "05" Valid ExistCpo("SX5","05"+_cTipoSE2) Picture "@!"  SIZE 10, 11 OF oPanel PIXEL HASBUTTON
	@ 057, 081 MSGET oTitSE2  VAR _cNumSE2	SIZE 42, 11 OF oPanel PIXEL
	@ 057, 126 MSGET oNatSE2  VAR _cNatSE2	F3 "SED" Valid ExistCPO("SED",_cNatSE2) SIZE 55, 11 OF oPanel PIXEL HASBUTTON
	@ 057, 181 MSGET oVencSE2 VAR _dVencSE2	VALID _dVencSE2 >= dDataBase SIZE 42, 11 OF oPanel PIXEL HASBUTTON

	DEFINE SBUTTON FROM 07, 230 TYPE 1 ACTION ( Eval(_bValid),;
	If( nOk==1,Eval({|| _nOpca:=1,oDlg:End() }), If(nOk==2,MsgAlert(cOkMsg2),MsgAlert(cOkMsg3)) ) ) ENABLE OF oDlg
	DEFINE SBUTTON FROM 21, 230 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	IF _nOpca == 1 // confirmou
		_lRet := .T.
	ENDIF

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11TitบAutor  ณMicrosiga           บ Data ณ  04/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera็ใo dos tํtulos a pagar/receber                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN11Tit(_cCat,_cParcela,oSay)

	Local aAreaSE1 := SE1->(GetArea())
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaSM0 := SM0->(GetArea())
	Local aStru     := {}
	Local cFilBak  := cFilAnt
	Local lBxTitOrig := .F.

	lMsErroAuto    := .F.

	IF _cCat == "R"

		IF _cTpMutuo == "2" 							// Mutuo - CR
			cFilAnt := SZX->ZX_CODEMP
		ENDIF

		SA1->( dbSetOrder(1) )
		SA1->( dbSeek(xFilial("SA1")+SZX->(ZX_CODCLI+ZX_LOJCLI)) )

		aAdd( aStru, { 'E1_PREFIXO', _cPrefSE1        	   , NIL } )
		aAdd( aStru, { 'E1_NUM    ', _cNumSE1         	   , NIL } )
		aAdd( aStru, { 'E1_PARCELA', _cParcela			   , NIL } ) // Necessario inserir parcela devido PK => E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		aAdd( aStru, { 'E1_TIPO   ', _cTipoSE1        	   , NIL } )
		aAdd( aStru, { 'E1_CLIENTE', SZX->ZX_CODCLI    	   , NIL } )
		aAdd( aStru, { 'E1_LOJA   ', SZX->ZX_LOJCLI    	   , NIL } )
		aAdd( aStru, { 'E1_NATUREZ', _cNatSE1         	   , NIL } )
		aAdd( aStru, { 'E1_EMISSAO', dDataBase        	   , NIL } )
		aAdd( aStru, { 'E1_VENCTO ', _dVencSE1       	   , NIL } )
		aAdd( aStru, { 'E1_VENCREA', DataValida(_dVencSE1) , NIL } )
		aAdd( aStru, { 'E1_VALOR  ', SZX->ZX_VALOR    	   , NIL } )
		aAdd( aStru, { 'E1_CREDIT ', SZX->ZX_CREDIT	   	   , NIL } )
		aAdd( aStru, { 'E1_CCC    ', SZX->ZX_CCC  	       , NIL } )
		aAdd( aStru, { 'E1_ITEMC  ', SZX->ZX_ITEMC	       , NIL } )
		aAdd( aStru, { 'E1_CLVLCR ', SZX->ZX_CLVLCR	       , NIL } )
		aAdd( aStru, { 'E1_EC05CR ', SZX->ZX_EC05CR	   	   , NIL } )
		aAdd( aStru, { 'E1_EC06CR ', SZX->ZX_EC06CR	   	   , NIL } )
		aAdd( aStru, { 'E1_EC07CR ', SZX->ZX_EC07CR	   	   , NIL } )
		aAdd( aStru, { 'E1_EC08CR ', SZX->ZX_EC08CR		   , NIL } )
		aAdd( aStru, { 'E1_EC09CR ', SZX->ZX_EC09CR		   , NIL } )
		aAdd( aStru, { 'E1_XMUTUO ', SZX->ZX_RATEIO    	   , NIL } )
		aAdd( aStru, { 'E1_XSTATUS', "2"               	   , NIL } )
		aAdd( aStru, { 'E1_XORIGEM', "3"             	   , NIL } )
		aAdd( aStru, { 'E1_XMANUAL', Iif(_lManual,"1","2") , NIL } )

		oSay:cCaption := ( "Incluindo Tํtulo a Receber (Pref/N๚m/Parc/Tp): " + RTrim(_cPrefSE1) + "/" + RTrim(_cNumSE1) + "/" + RTrim(_cParcela) + "/" + RTrim(_cTipoSE1) )
		ProcessMessages()

		MSExecAuto( { | x, y | Fina040( x, y ) }, aStru, 3 )

		DbSelectArea("SZE")
		SZE->(DbSetOrder(2), DbGoTop())

		If SZE->(DbSeek(xFilial("SZE")+cFilAnt)) .and. SZE->ZE_CODCLI == SZX->ZX_CODCLI .and. SZE->ZE_LOJCLI == SZX->ZX_LOJCLI
			lBxTitOrig := .T.
		ElseIf SZX->ZX_CODEMP == _cFilOrig
			lBxTitOrig := .T.
		EndIf

		If lBxTitOrig
			oSay:cCaption := ( "Baixando Tํtulo a Receber (Pref/N๚m/Parc/Tipo): " + RTrim(_cPrefSE1) + "/" + RTrim(_cNumSE1) + "/" + RTrim(_cParcela) + "/" + RTrim(_cTipoSE1) )
			ProcessMessages()
			DbSelectArea("SE1")
			SIFIN11Bxa( "SE1" , _cCat , _cTpMutuo , _cParcela)	// Baixa titulo Ctas a Receber na Emp/Fil Centralizadora
		EndIf

	Else
		If _cTpMutuo == "1" 								// Mutuo  CP
			cFilAnt := SZX->ZX_CODEMP
		EndIf

		_cParcela := PadR( _cParcela, GetSx3Cache( "E2_PARCELA","X3_TAMANHO") )

		aAdd( aStru, { 'E2_PREFIXO', _cPrefSE2             , NIL } )
		aAdd( aStru, { 'E2_NUM    ', _cNumSE2              , NIL } )
		aAdd( aStru, { 'E2_PARCELA', _cParcela             , NIL } )
		aAdd( aStru, { 'E2_TIPO   ', _cTipoSE2             , NIL } )
		aAdd( aStru, { 'E2_FORNECE', SZX->ZX_CODFOR        , NIL } )
		aAdd( aStru, { 'E2_LOJA   ', SZX->ZX_LOJFOR        , NIL } )
		aAdd( aStru, { 'E2_NATUREZ', _cNatSE2              , NIL } )
		aAdd( aStru, { 'E2_EMISSAO', dDataBase             , NIL } )
		aAdd( aStru, { 'E2_VENCTO ', _dVencSE2        	   , NIL } )
		aAdd( aStru, { 'E2_VENCREA', DataValida(_dVencSE2) , NIL } )
		aAdd( aStru, { 'E2_VALOR  ', SZX->ZX_VALOR         , NIL } )
		aAdd( aStru, { 'E2_CONTAD ', SZX->ZX_DEBITO	   	   , NIL } )
		aAdd( aStru, { 'E2_CCD    ', SZX->ZX_CCD  	       , NIL } )
		aAdd( aStru, { 'E2_ITEMD  ', SZX->ZX_ITEMD	       , NIL } )
		aAdd( aStru, { 'E2_CLVLDB ', SZX->ZX_CLVLDB	       , NIL } )
		aAdd( aStru, { 'E2_EC05DB ', SZX->ZX_EC05DB	   	   , NIL } )
		aAdd( aStru, { 'E2_EC06DB ', SZX->ZX_EC06DB	   	   , NIL } )
		aAdd( aStru, { 'E2_EC07DB ', SZX->ZX_EC07DB	   	   , NIL } )
		aAdd( aStru, { 'E2_EC08DB ', SZX->ZX_EC08DB		   , NIL } )
		aAdd( aStru, { 'E2_EC09DB ', SZX->ZX_EC09DB		   , NIL } )
		aAdd( aStru, { 'E2_XMUTUO' , SZX->ZX_RATEIO        , NIL } )
		aAdd( aStru, { 'E2_XSTATUS', "2"               	   , NIL } )
		aAdd( aStru, { 'E2_XORIGEM', "3"             	   , NIL } )
		aAdd( aStru, { 'E2_XMANUAL', Iif(_lManual,"1","2") , NIL } )

		SZY->(dbSetOrder(1))
		If SZY->(dbSeek(XFilial("SZY")+SZX->(ZX_RATEIO+ZX_ITEM)))
			aAdd( aStru, { 'E2_RATEIO' , "S"             	   , NIL } )
		EndIf

		oSay:cCaption := ( "Incluindo Tํtulo a Pagar (Pref/N๚m/Tipo): " + RTrim(_cPrefSE2) + "/" + RTrim(_cNumSE2) + "/" + RTrim(_cTipoSE2) )
		ProcessMessages()

		MSExecAuto( { | x, y, z | Fina050( x, y, z ) }, aStru,, 3 )

		DbSelectArea("SZE")
		SZE->(DbSetOrder(2), DbGoTop())

		If SZE->(DbSeek(xFilial("SZE")+cFilAnt)) .and. SZE->ZE_CODFOR == SZX->ZX_CODFOR .and. SZE->ZE_LOJFOR == SZX->ZX_LOJFOR
			lBxTitOrig := .T.
		ElseIf SZX->ZX_CODEMP == _cFilOrig
			lBxTitOrig := .T.
		EndIf

		If lBxTitOrig

			If AllTrim(_cParcela) == '1'

				oSay:cCaption := ( "Baixando Tํtulo a Pagar (Pref/N๚m/Tipo): " + RTrim(_cPrefSE2) + "/ " + RTrim(_cNumSE2) + "/" + RTrim(_cTipoSE2) )
				ProcessMessages()
				DbSelectArea("SE2")

				SIFIN11Bxa( "SE2" , _cCat , _cTpMutuo , _cParcela )	// Baixa titulo Ctas a Pagar na Emp/Fil Centralizadora

			End If

		EndIf

	EndIf

	If lMsErroAuto
		If (__lSX8)
			RollBackSX8()
		EndIf

		DisarmTransaction()

		MostraErro()

		cFilAnt := cFilBak 							// Restaura
		Break
	Else
		If (__lSX8)
			ConfirmSX8()
		EndIf
	EndIf

	cFilAnt := cFilBak
	RestArea(aAreaSM0)
	RestArea(aAreaSE1)
	RestArea(aAreaSE2)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11Bxaบ Autor ณ TOTVS              บ Data ณ  06/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Efetua a Baixa do Titulo do Contas a Pagar/Receber da      บฑฑ
ฑฑบ          ณ gerado para a Empresa/Filial Centralizadora do Titulo.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN11Bxa( cAlias , _cCat , _cTpMutuo , _cParcela )

	Local aBaixa      := {}
	Local lHelp       := .T.
	Local lBaixou     := .T.
	Local aAreaAlias  := (cAlias)->(GetArea())
	Local lNoBrowse   := .F.
	Local nOpcBaixa	  := 0

	lMSHelpAuto := .F.
	lMsErroAuto := .F.

	If _cCat == "P"

		Begin Transaction		// Faz a liberacao do titulo para Baixa
			dbSelectArea( cAlias )
			RecLock(cAlias,.F.,.t.)
			SE2->E2_DATALIB := dDataBase
			SE2->E2_USUALIB := cUsername
			MsUnlock()
		End Transaction

		// Monta array a ser utilizado para baixa
		aBaixa	:= {	{"E2_PREFIXO",	_cPrefSE2,					Nil},;
		{"E2_NUM",		_cNumSE2,					Nil},;
		{"E2_PARCELA",	_cParcela,                  Nil},;
		{"E2_TIPO",		_cTipoSE2,					Nil},;
		{"E2_SALDO",	SZX->ZX_VALOR,				Nil},;
		{"E2_VALLIQ",	0,							Nil},;
		{"ATUCHEQUE",	" ",						Nil},;
		{"AUTBANCO",	" ",						Nil},;
		{"AUTAGENCIA",	" ",						Nil},;
		{"AUTCONTA",	" ",						Nil},;
		{"AUTMOTBX",	cCodMotBx,					Nil},;
		{"AUTDTBAIXA",	dDataBase,					Nil},;
		{"AUTHIST",		"Baixa do Mutuo por Dacao", Nil},;
		{"AUTVLRPG",	SZX->ZX_VALOR,				Nil},;
		{"AUTDESCONT",	0,							Nil},;
		{"AUTMULTA",	0,							Nil},;
		{"AUTJUROS",	0,							Nil}}

		MSExecAuto({|x,y,z| FINA080(x,y,z)}, aBaixa, 3)		// Execu็ใo da Baixa Automแtica de Tํtulo a Pagar


	ElseIf _cCat == "R"

		// Monta array a ser utilizado para baixa
		aBaixa	:= {	{"E1_PREFIXO",	_cPrefSE1,					Nil},;
		{"E1_NUM",		_cNumSE1,					Nil},;
		{"E1_PARCELA",	PadR(_cParcela,TamSX3("E1_PARCELA")[1]),Nil},;
		{"E1_TIPO",		_cTipoSE1,					Nil},;
		{"AUTMOTBX",	cCodMotBx,					Nil},;
		{"AUTVALREC",	SZX->ZX_VALOR,				Nil},;
		{"AUTDTBAIXA",	dDataBase,					Nil},;
		{"AUTHIST",		"Baixa do Mutuo por Dacao", Nil},;
		{"E1_DESCONT",	0,							Nil},;
		{"E1_MULTA",	0,							Nil},;
		{"E1_JUROS",	0,							Nil},;
		{"E1_VALJUR",	0,							Nil},;
		{"AUTDTCREDITO",dDataBase,					Nil}}

		MSExecAuto({|x, y , z, w| FINA070(x, y , z, w)}, aBaixa, 3, lNoBrowse, nOpcBaixa)

	EndIf

	If lMsErroAuto
		If lHelp
			MsgAlert("Verifique a baixa referente ao tํtulo da Empresa Centralizadora pois nใo foi gerado.","Baixa do M๚tuo por Da็ใo")
			lBaixou	:= .F.
		EndIf
	Endif

	RestArea(aAreaAlias)

Return lBaixou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN11RatบAutor  ณMicrosiga           บ Data ณ  04/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualizacao do rateio contabil                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN11Rat(_cItem,_nVal,_nOpc)
	Local _lOk       := .f.
	Local cFieldOk   := "AllwaysTrue"
	Local cSuperDel  := ""
	Local cDelOk     := "AllwaysTrue"
	// Backup das variaveis da GD
	Local _aHeadAnt  := aClone(aHeader)
	Local _aColsAnt  := aClone(aCols)
	Private aHeader  := {}
	Private aCols    := {}
	Private aHeader1 := {}
	Private aCols1   := {}
	Private _nVrCC   := _nVal
	Private _nRatCC  := 0
	Private oRatCC

	// Cria acols da SZY
	FillGetDados(3,"SZY",1,,,{|| .T. },aNaoSZY,/*aSimCpo*/,,,,.t.,aHeader1,aCols1)

	_aVetor := {}
	For i := 1 to Len(aBkpCols)
		IF GdFieldGet("ZY_ITEMRAT",i,,aBkpHead,aBkpCols) == _cItem
			Aadd(_aVetor,aClone(aBkpCols[i]))
		ENDIF
	Next

	IF Len(_aVetor) > 0
		aCols  := aClone(_aVetor)
		aCols1 := aClone(_aVetor)
	ENDIF

	IF Empty(GdFieldGet("ZY_ITEM",1,,aHeader1,aCols1))
		GDFieldPut("ZY_ITEM",StrZero(1,TamSX3("ZY_ITEM")[1]),1,aHeader1,aCols1)
	ELSE
		// Atualiza valor total caso o rateio financeiro tenha sido alterado
		aEval(aCols1,{|x| x[GDFieldPos("ZY_VALOR",aHeader1)] := _nVrCC * (x[GDFieldPos("ZY_PERCEN",aHeader1)]/100) })
	ENDIF

	DEFINE FONT oFnt 	NAME "Arial" SIZE 0, -11 BOLD

	DEFINE MSDIALOG oDlgRat FROM 100,100 TO 400,800 TITLE "Rateio Contแbil" Of oMainWnd PIXEL
	oPanel := TPanel():New(0,0,'',oDlgRat,, .T., .T.,, ,25,25,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_BOTTOM
	nStyle := GD_INSERT+GD_DELETE+GD_UPDATE
	oRat := MsNewGetDados():New(1,1,1,1,nStyle,"U_SIFIN11LOK(2)","AllwaysTrue","+ZY_ITEM", , /*nFreeze*/,9999,cFieldOk,cSuperDel,cDelOk,oDlgRat,aHeader1,aCols1)
	oRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oRat:oBrowse:bChange := {|| GDFieldPut("ZY_ITEMRAT",_cItem,oRat:oBrowse:nAt,oRat:aHeader,oRat:aCols) , oRat:oBrowse:Refresh() }

	// bloqueia quando nao for inclusao ou alteracao
	IF !(_nOpc == 1 .or. _nOpc == 2)
		oRat:OBROWSE:NOPC := 2
	ENDIF

	// Atualiza total do rateio
	aEval( aCols1, {|Linha| _nRatCC += Linha[GDFieldPos("ZY_VALOR",aHeader1)]  } )

	@ 010,005 SAY OemToAnsi("Valor para Rateio: ") Of oPanel PIXEL	FONT oFnt
	@ 008,065 MSGET oTotal 	VAR _nVrCC Picture X3Picture("ZX_VALOR") Of oPanel READONLY SIZE 60,10 PIXEL

	@ 010,150 SAY OemToAnsi("Total Rateado: ") Of oPanel PIXEL	FONT oFnt
	@ 008,200 MSGET oRatCC 	VAR _nRatCC Picture X3Picture("ZX_VALOR") Of oPanel READONLY SIZE 60,10 PIXEL

	ACTIVATE MSDIALOG oDlgRat CENTERED ON INIT EnchoiceBar(oDlgRat,{|| Iif(oRat:TudoOk() .and. SIFIN11TOK(2,_nOpc),(_lOk:=.t.,oDlgRat:End(),aBkpHead := oRat:aHeader),(_lOk:=.f.))},{||oDlgRat:End()})

	SetKey( VK_F7, _bRateio )

	// Restaura variaveis da GD
	aHeader := aClone(_aHeadAnt)
	aCols   := aClone(_aColsAnt)
Return()
