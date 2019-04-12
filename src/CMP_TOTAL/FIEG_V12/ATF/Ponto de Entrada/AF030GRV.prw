#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} AF030GRV
Gravar o número do processo no campo N1_XPROCES e data no campo N1_XDTPROC na rotina de Baixa de ativo ATFA030.

@type function
@author Tiago Alexandrino
@since 17/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function AF030GRV()

	Local nOpcA    := 0
	Local aArea    := GetArea()
	Local aAreaSN1 := SN1->(GetArea())
	Local cProcess := Space(20)
	Local dDtProc  := dDatabase

	Local oDlg     := NIL
	Local oProcess := Nil
	Local oDtProc  := Nil
	Local llTela	:= .T.
	Local llInfoOk	:= .F.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF FUNNAME() == "ATFA030"
		IF IsInCallStack("AF030AUTO")
			//-------------------------------------------------------------------------------------------------
			//- Variaveis sao manipuladas no ponto de entrada AF030AUTBT, para ficarem nulas sempre no inicio -
			//- do processo da baixa automatica de ativos.                                                    -
			//-------------------------------------------------------------------------------------------------
			IF Type("_cpProcess") == "U"
				Public _cpProcess := ""
			ENDIF

			IF Type("_dpDtProc") == "U"
				Public _dpDtProc := CtoD( "//" )
			ENDIF

			llInfoOk :=  !( Type("_cpProcess") == "U" .AND. Type("_dpDtProc") == "U" ) .AND. Empty( _cpProcess ) .AND. Empty( _dpDtProc )
			llTela := llInfoOk
		ENDIF

		IF llTela
			DEFINE MSDIALOG oDlg FROM  98,1 TO 190,402 TITLE "Dados do Contrato" PIXEL STYLE DS_MODALFRAME STATUS
			oDlg:lEscClose  := .F.

			@ 10,10  SAY "Processo: " SIZE 50,8  OF oDlg PIXEL
			@ 09,35  MSGET oProcess VAR cProcess SIZE 60,06 OF oDlg PIXEL
			@ 10,120  SAY "DT Processo: " SIZE 50,8 OF oDlg PIXEL
			@ 09,155 MSGET oDtProc VAR dDtProc SIZE 40,06 OF oDlg PIXEL

			// Criação do botão Ok na tela criada acima
			DEFINE SBUTTON FROM 28,155 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())

			ACTIVATE MSDIALOG oDlg NOMODAL CENTERED ON INIT (nOpca := 1, .F.)	// Zero nOpca caso para saida com ESC
		ENDIF

		IF IsInCallStack("AF030AUTO")
			IF llInfoOk
				_cpProcess := cProcess
				_dpDtProc := dDtProc
			ELSE
				cProcess := _cpProcess
				dDtProc := _dpDtProc
				nOpcA := 1
			ENDIF
		ENDIF

		IF nOpcA == 1 .AND. !Empty(cProcess)
			// Atualiza processo
			RecLock("SN1",.F.)
			SN1->N1_XPROCES := cProcess
			SN1->N1_XDTPROC := dDtProc
			SN1->(MsUnlock())
		ENDIF
	ENDIF

	//Restaura as areas
	RestArea(aAreaSN1)
	RestArea(aArea)

Return NIL