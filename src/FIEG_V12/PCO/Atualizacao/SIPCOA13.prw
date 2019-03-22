#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA13
Consulta status dos Centros de Custo e verifica Planilha.

@type function
@author Claudinei Ferreira
@since 22/01/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIPCOA13
	Local nI
	Local aArea     := GetArea()
	Local aAreaCTT  := CTT->(GetArea())
	Local aAreaAK2  := AK2->(GetArea())
	Local aButtons  := {}
	Local cTitulo	:= "Status dos UOs (Centros de Custos)"
	Local aVet		:= {}
	Local oDlg      := NIL
	Local lSegue    := .T.
	Private oLbx    := NIL

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+----------------------------------+
	//|Valida se existe registros na CTT |
	//+----------------------------------+
	If Len( aVet := _PCO13Atu(.f.,0) ) == 0
		MsgAlert("Não foram encontrados registros no cadastro de Centro Custo (UO)", "ATENCAO!!!")
		lSegue := .F.
	Endif

	If lSegue .And. AK1->AK1_FILIAL <> XFILIAL("AK1")
		MsgStop("Empresa selecionada diferente da filial corrente. Verifique!")
		lSegue := .F.
	Endif

	If lSegue

		SetKey( VK_F5, { || _PCO13Atu(.t.,0) } )

		//+-------------------------------+
		//|Monta a Tela de Responsaveis UO|
		//+-------------------------------+
		DEFINE FONT oFont   NAME 'Arial' SIZE 6, -13 BOLD
		DEFINE FONT oFontF3 NAME 'Arial' SIZE 12, -13 BOLD

		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 550,800 PIXEL STYLE DS_MODALFRAME STATUS
		oDlg:lMaximized := .F.
		oDlg:lEscClose  := .F.

		@ 16,02 LISTBOX oLbx VAR cVar FIELDS HEADER ;
		"","UOS", "Descrição", "Responsável","E-mail", "Telefone" SIZE 322,245 OF oDlg PIXEL //ColSizes 20,15,22,15,30,25,30,25,45,15,30,25,85,30,30,30

		oLbx:SetArray( aVet )
		oLbx:bLine := {|| {aVet[oLbx:nAt,01],;
		aVet[oLbx:nAt,02],;
		aVet[oLbx:nAt,03],;
		aVet[oLbx:nAt,04],;
		aVet[oLbx:nAt,05],;
		Transform(aVet[oLbx:nAt,06],"@R (99) 9999-9999")}}

		oLbx:Refresh()

		oLbx:Align := CONTROL_ALIGN_TOP

		@ 252,010 BITMAP oBmp1 RESOURCE "ENABLE" SIZE 7,7 OF oDlg PIXEL ON CLICK _PCO13Atu(.t.,1)
		@ 253,020 SAY "Em Aberto " SIZE 40,8 FONT oFont COLOR CLR_HBLUE OF oDlg PIXEL
		oBmp1:cToolTip := "Filtrar UO's em aberto"

		@ 252,060 BITMAP oBmp2 RESOURCE "DISABLE" SIZE 7,7 OF oDlg PIXEL ON CLICK _PCO13Atu(.t.,2)
		@ 253,070 SAY "Finalizada " SIZE 40,8 FONT oFont COLOR CLR_HBLUE OF oDlg PIXEL
		oBmp2:cToolTip := "Filtrar UO's em finalizadas"

		@ 252,110 BITMAP oBmp3 RESOURCE "BR_CINZA" SIZE 7,7 OF oDlg PIXEL ON CLICK _PCO13Atu(.t.,3)
		@ 253,120 SAY "UO sem movimento" SIZE 50,8 FONT oFont COLOR CLR_HBLUE OF oDlg PIXEL
		oBmp3:cToolTip := "Filtrar UO's não cadastradas na Planilha"

		@ 252,200 SAY "F5 - Remove Filtros" SIZE 100,8 FONT oFontF3 COLOR CLR_HBLUE OF oDlg PIXEL

		//ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)
		Define SButton From 258, 365 Type 2 Action ( oDlg:End() ) OnStop "Fechar" Enable Of oDlg
		Activate MSDialog  oDlg Center


		SetKey( VK_F5  , NIL )

		RestArea(aAreaCTT)
		RestArea(aAreaAK2)
		RestArea(aArea)

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} _PCO13Atu
Atualização da grid.

@type function
@author Thiago Rasmussen
@since 16/03/2012
@version P12.1.23

@param _lRefresh, Lógico, Indica refesh da tela.
@param _nStatus, Numérico, Status do centro de custo.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/

Static Function _PCO13Atu(_lRefresh,_nStatus)
	Local oOk       := LoadBitmap( GetResources(), "ENABLE" )
	Local oNo       := LoadBitmap( GetResources(), "DISABLE" )
	Local oNc       := LoadBitmap( GetResources(), "BR_CINZA" )
	Local _aAreaAK2 := AK2->(GetArea())
	Local _aAreaCTT := CTT->(GetArea())
	Local _aRet     := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+----------------------------+
	//|Carrega o Vetor do LISTBOX  |
	//+----------------------------+
	CTT->(dbSetOrder(1))
	CTT->(dbSeek(XFilial("CTT")))

	While CTT->(!Eof()) .and. CTT->CTT_FILIAL == XFilial("CTT")
		// Filtra somente CC analiticos
		IF CTT->CTT_CLASSE == "2" .and. PcoDirCC_User(CTT->CTT_CUSTO,__CUSERID) <> 0

			// Tratamento do semaforo
			AK2->(dbSetOrder(8))
			IF !AK2->(dbSeek(XFilial("AK2")+AK1->(AK1_CODIGO+AK1_VERSAO)+CTT->CTT_CUSTO))
				oSt := oNc
			ELSE
				oSt := oNo
				While AK2->(!Eof()) .and. AK2->AK2_FILIAL == XFilial("AK2") .and. AK2->(AK2_ORCAME+AK2_VERSAO+AK2_CC) == AK1->(AK1_CODIGO+AK1_VERSAO)+CTT->CTT_CUSTO
					IF AK2->AK2_XSTS == "0"
						oSt := oOk
					ENDIF
					AK2->(dbSkip())
				Enddo
			ENDIF

			// Validação de filtros
			IF (_nStatus == 1 .and. oSt <> oOk) .or. (_nStatus == 2 .and. oSt <> oNo) .or. (_nStatus == 3 .and. oSt <> oNc)
				CTT->(dbSkip())
				Loop
			ENDIF

			Aadd(_aRet, {oSt,CTT->(CTT_CUSTO),CTT->(CTT_DESC01),UsrRetName(CTT->(CTT_USER)),UsrRetMail(CTT->(CTT_USER)),CTT->(CTT_XTEL)})
		ENDIF

		CTT->(dbSkip())
	Enddo

	IF _lRefresh // atualiza grid
		oLbx:SetArray( _aRet )
		oLbx:bLine := {|| {_aRet[oLbx:nAt,01],;
		_aRet[oLbx:nAt,02],;
		_aRet[oLbx:nAt,03],;
		_aRet[oLbx:nAt,04],;
		_aRet[oLbx:nAt,05],;
		Transform(_aRet[oLbx:nAt,06],"@R (99) 9999-9999")}}

		oLbx:Refresh() // Refresh de tela
	ENDIF

	RestArea(_aAreaAK2)
	RestArea(_aAreaCTT)
Return(_aRet)
