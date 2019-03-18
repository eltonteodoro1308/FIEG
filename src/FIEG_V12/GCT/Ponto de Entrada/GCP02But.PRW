#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} GCP02But
Ponto de Entrada para inclusao de botao na tela do edital.

@type function
@author Thiago Rasmussen
@since 12/01/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com os botões a serem incluídos na tela.

/*/
/*/================================================================================================================================/*/

User Function GCP02But()
	Local cEdital := PARAMIXB[2], cNumProEdt := PARAMIXB[3], cItem := PARAMIXB[4]
	Local aBut := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aAdd(aBut,{'Email Processo',{|| U_FRJA026()},"Email Processo", "Email Processo"})
	aAdd(aBut,{'Alterar Objeto',{|| xTelaCoTa()},"Alterar Objeto", "Alterar Objeto"})

	IF INCLUI
		_cNum := GetMV("SI_NUMEDT")
		M->CO1_CODEDT := _cNum
	ENDIF


	if __lGCPCNI1
		//Se o Edital já passou por um estorno nao deixou mais Editar nada
		if !U_SICOMA34 (14, cEdital, cNumProEdt, cItem) //Verifica se o Edital passou por um processo de estorno em algum momento

			aAdd(aBut,{'Edicao',PARAMIXB[5],"Edição", "Edição"})
		EndIf
	EndIf

	If PARAMIXB[1] == 4
		aAdd(aBut,{"Lote",	{|| oGetEdt:oBrowse:lDisablePaint:=.T.,	;
		u_SICOMA25(),			;
		oGetEdt:oBrowse:lDisablePaint:=.F.},	;
		"Lote",									;
		"Lote"})
	EndIf

Return aBut

/*/================================================================================================================================/*/
/*/{Protheus.doc} xTelaCoTa
Função executada ao selecionar a rotina "Alterar Objeto".

@type function
@author Thiago Rasmussen
@since 12/01/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xTelaCoTa()

	Local oMemo
	Local cGet1     := Space(50)
	Local oSay2     := Nil
	Local cGet2     := Space(500)
	Local oSay1     := Nil
	Local oSButton1 := Nil
	Local oSButton2 := Nil
	Local cQuery    := ""
	Local cNumObj	:= CO1->CO1_OBJETO
	Local cNumEdt   := CO1->CO1_CODEDT
	Local cNumPrc   := CO1->CO1_NUMPRO
	Private oDlg      := Nil

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cGet1 	:= M->CO1_PCHAVE

	If cGet1 <> Space(50)
		//cGet2 	:= POSICIONE("OBJ",1,xFilial("OBJ")+"ED"+cNumObj,"OBJ_DESCRI")
		cGet2 := POSICIONE("OBJ",1,xFilial("OBJ")+cNumObj,"OBJ_DESCRI")
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Parametros" FROM 000, 000  TO 350, 800 COLORS 0, 16777215 PIXEL

	@ 012, 012 SAY oSay2 PROMPT "Palavra Chave:" SIZE 053, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 012, 082 MSGET oGet1 VAR cGet1 OF oDlg COLORS 0, 16777215 PIXEL
	@ 034, 012 SAY oSay1 PROMPT "Descrição do Objeto:" SIZE 053, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 036, 080 GET oMemo VAR cGet2 OF oDlg MEMO size 300,100		  PIXEL


	DEFINE SBUTTON oSButton1 FROM 160, 355 TYPE 01 OF oDlg ENABLE ACTION(IIF(Empty(cGet2) .OR. Empty(cGet1),MsgStop("Os campos Palavra Chave e Objeto são obrigatórios."),U_GrvObj({cGet1,cGet2},"1",CO1->CO1_OBJETO)))


	ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} function_method_class_name
Tela de Preenchimento do campo Objeto.

@type function
@author Jader Berto / Doit Sistemas
@since 06/04/2015
@version P12.1.23

@param aTela, array, descricao
@param cTipo, characters, descricao
@param cNumObj, characters, descricao

@obs Projeto ELO

@history 06/04/2015, jaderberto@gmail.com, Tela de Preenchimento do campo Objeto.
@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function GrvObj(aTela, cTipo, cNumObj)
	//Local cGet1   := ""
	Local _cGetOBJ:= ""
	//Local __lGCPCNI1 := .T.
	Local aArea 	:= GETAREA()
	Local cPalaChav := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cPalaChav	 := UPPER(aTela[1])
	_cGetOBJ 	 := UPPER(aTela[2])

	If !Empty(_cGetOBJ)

		DbSelectArea("OBJ")
		OBJ->(DBSetOrder(1))

		If cNumObj = ""
			cNumObj := "FIRJAN"
		EndIf
		//If OBJ->(DbSeek(xFilial("OBJ")+"ED"+cNumObj))
		If OBJ->(DbSeek(xFilial("OBJ") + cNumObj))
			OBJ->(Reclock("OBJ",.F.))
			OBJ->OBJ_DESCRI	:= _cGetOBJ
			OBJ->(MsUnlock())
		Else
			//cNumObj := GETSXENUM("OBJ","OBJ_NUM")
			cNumObj := U_NXNUMOBJ()

			OBJ->(Reclock("OBJ",.T.))
			OBJ->OBJ_FILIAL := xFilial("OBJ")
			OBJ->OBJ_ORIGEM := "ED"
			OBJ->OBJ_NUM	:= cNumObj
			OBJ->OBJ_DOC    := cNumEdt
			OBJ->OBJ_PROC   := cNumPrc
			OBJ->OBJ_DESCRI	:= _cGetOBJ
			OBJ->(MsUnlock())
		EndIf
		OBJ->(DBCloseArea())
		/*
		cCommand := " UPDATE " +RetSqlName("CO1")
		cCommand += " SET CO1_OBJETO = '"+cNumObj+"' "
		cCommand += " WHERE CO1_FILIAL = '"+xFilial("CO1")+"' "
		cCommand += " AND CO1_CODEDT = '"+cCodEdt+"' "

		//+-------------------------------------+
		//|Executa expressao SQL e atualiza TOP |
		//+-------------------------------------+
		BeginTran()
		TcSqlExec(cCommand)
		TcRefresh(RetSqlName("CO1"))
		EndTran()
		*/

		M->CO1_PCHAVE := cPalaChav
		M->CO1_OBJETO := cNumObj
		RecLock("CO1",.F.)
		CO1->CO1_PCHAVE := cPalaChav
		CO1->CO1_OBJETO := cNumObj
		CO1->(MsUnLock())

		//OBJ->(ConfirmSX8())
		cNumObj := ""
	EndIf

	Aviso("Confirmação", "Objeto alterado com sucesso.", {"Ok"})

	If cTipo = "1"
		oDlg:End()
	EndIf

	RestArea(aArea)

Return