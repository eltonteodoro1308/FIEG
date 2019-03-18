#Include "Protheus.ch"
#Include "FWMBrowse.ch"
#Include "FWMVCDef.ch"
#Include "TBICONN.ch"

Static cTitulo     := "Manutenção do Inventário"
Static _MV_XUSUINV := SuperGetMV("MV_XUSUINV", .F.)

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATFA999
Formulário de Manutenção de Inventário.

@type function
@author Thiago Rasmussen
@since 17/04/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ATFA999()
	Local aArea       := GetArea()
	Local oBrowse

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZZX")

	oBrowse:SetDescription(cTitulo)

	oBrowse:AddLegend( "ALLTRIM(ZZX->ZZX_STATUS) == 'ABERTO'",     "GREEN",  "ABERTO" )
	oBrowse:AddLegend( "ALLTRIM(ZZX->ZZX_STATUS) == 'ENCERRADO'",  "YELLOW", "ENCERRADO" )
	oBrowse:AddLegend( "ALLTRIM(ZZX->ZZX_STATUS) == 'FINALIZADO'", "RED",    "FINALIZADO" )

	oBrowse:Activate()

	RestArea(aArea)
Return Nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} MenuDef
Monta o array aRotina com as rotinas do Browse.

@type function
@author Thiago Rasmussen
@since 17/04/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array aRotina com as rotinas do Browse.

/*/
/*/================================================================================================================================/*/

Static Function MenuDef()
	Local aRot := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	ADD OPTION aRot TITLE 'Visualizar'              ACTION 'VIEWDEF.ATFA999' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	//ADD OPTION aRot TITLE 'Incluir'               ACTION 'VIEWDEF.ATFA999' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	//ADD OPTION aRot TITLE 'Alterar'               ACTION 'VIEWDEF.ATFA999' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	//ADD OPTION aRot TITLE 'Excluir'               ACTION 'VIEWDEF.ATFA999' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	//ADD OPTION aRot TITLE 'Legenda'               ACTION 'U_zMVC01Leg' OPERATION 6 ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Iniciar inventário'      ACTION 'FWMsgRun(,{|| U_ImportarInventario(.T.)},"Iniciar Inventário","Aguarde..")' OPERATION 9 ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Complementar inventário' ACTION 'FWMsgRun(,{|| U_ImportarInventario(.F.)},"Complementar Inventário","Aguarde..")' OPERATION 9 ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Status - Aberto'         ACTION 'U_AlterarStatus("ABERTO")' OPERATION 9 ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Status - Encerrado'      ACTION 'U_AlterarStatus("ENCERRADO")' OPERATION 9 ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Status - Finalizado'     ACTION 'U_AlterarStatus("FINALIZADO")' OPERATION 9 ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Imprimir'                ACTION 'FWMsgRun(,{|| U_ImprimirInventario()},"Imprimir Inventário","Aguarde..")' OPERATION 9 ACCESS 0 //OPERATION X

	// Tipo de operação (1=Visualizar, 2=Visualizar,3=Incluir,4=Alterar, 5=Excluir, 6=Alterar sem inclusão de novas linhas, 7=Cópia e 8=Impressão da regra de negócios)
Return aRot


/*/================================================================================================================================/*/
/*/{Protheus.doc} ModelDef
Monta o Objeto que representa o Modelo de Dados.

@type function
@author Thiago Rasmussen
@since 17/04/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto que representa o Modelo de Dados.

/*/
/*/================================================================================================================================/*/

Static Function ModelDef()
	Local oModel   := Nil
	Local oStPai   := FWFormStruct(1, 'ZZX')
	Local oStFilho := FWFormStruct(1, 'ZZY')
	Local aZZYRel  := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oModel := MPFormModel():New('ATFA999M')
	oModel:AddFields('ZZXMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('ZZYDETAIL','ZZXMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

	aAdd(aZZYRel, {'ZZY_FILIAL', 'ZZX_FILIAL'} )
	aAdd(aZZYRel, {'ZZY_INVENT', 'ZZX_INVENT'})

	oModel:SetRelation('ZZYDETAIL', aZZYRel, ZZY->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('ZZYDETAIL'):SetUniqueLine({"ZZY_FILIAL","ZZY_CODATI"})    //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})

	//Setando as descrições
	oModel:SetDescription("Manutenção de Inventário")
	oModel:GetModel('ZZXMASTER'):SetDescription('Modelo Inventário')
	oModel:GetModel('ZZYDETAIL'):SetDescription('Modelo Itens do Inventário')
Return oModel


/*/================================================================================================================================/*/
/*/{Protheus.doc} ViewDef
Monta o Objeto que representa aView do Modelo de Dados.

@type function
@author Thiago Rasmussen
@since 17/04/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto que representa aView do Modelo de Dados.

/*/
/*/================================================================================================================================/*/
Static Function ViewDef()
	Local oView    := Nil
	Local oModel   := ModelDef()//FWLoadModel('ATFA999')
	Local oStPai   := FWFormStruct(2, 'ZZX')
	Local oStFilho := FWFormStruct(2, 'ZZY')

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_ZZX',oStPai,'ZZXMASTER')
	oView:AddGrid('VIEW_ZZY',oStFilho,'ZZYDETAIL')

	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)

	oView:SetOwnerView('VIEW_ZZX','CABEC')
	oView:SetOwnerView('VIEW_ZZY','GRID')

	oView:EnableTitleView('VIEW_ZZX','Inventário')
	oView:EnableTitleView('VIEW_ZZY','Itens do Inventário')
Return oView

/*/================================================================================================================================/*/
/*/{Protheus.doc} AlterarStatus
Altera o Status do inventário.

@type function
@author Thiago Rasmussen
@since 17/04/2018
@version P12.1.23

@param _STATUS, Caractere, Status do inventário.

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
User Function AlterarStatus(_STATUS)

	Local lSegue := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF !VerificarPermissao()
		lSegue := .F.
	ENDIF

	If lSegue

		IF ALLTRIM(ZZX->ZZX_STATUS) == _STATUS
			MsgInfo("O status atual do inventário posicionado já é " + ALLTRIM(ZZX->ZZX_STATUS) + "!", "ATFA999")

			lSegue := .F.
		ENDIF

		RecLock("ZZX",.F.)
		ZZX->ZZX_STATUS := _STATUS
		ZZX->ZZX_USURES := RetCodUsr()
		ZZX->ZZX_DATRES := Date()
		ZZX->ZZX_HORRES := Time()
		ZZX->ZZX_OBSRES := ALLTRIM(UsrFullName(RetCodUsr()))
		ZZX->(MsUnlock())

		MsgInfo("Status do inventário alterado com sucesso!" + CRLF + CRLF +;
		"Filial: " + ZZX->ZZX_FILIAL + CRLF +;
		"Inventário: " + ZZX->ZZX_INVENT + CRLF +;
		"Data: " + DtoC(ZZX->ZZX_DATA) + CRLF +;
		"Descrição: " + ZZX->ZZX_DESCRI + CRLF +;
		"Status: " + ZZX->ZZX_STATUS, "ATFA999")

	End If

Return NIL

/*/================================================================================================================================/*/
/*/{Protheus.doc} ImportarInventario
Descrição detalhada da função.

@type function
@author Thiago Rasmussen
@since 17/04/2018
@version P12.1.23

@param _INCLUIR, Lógico, Verdadeiro inicia inventário e Falso completa inventário

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ImportarInventario(_INCLUIR)

	Local cExt    := "Arquivo CSV | *.CSV"
	Local cPath   := ""
	Local cArq    := ""
	Local cLinha  := ""
	Local nLinha  := 0
	Local lPrim   := .T.
	Local aCampos := {}
	Local aDados  := {}
	Local _DATA   := DATE()
	Local _HORA   := TIME()
	Local _CODIGO := 0
	Local lSegue  := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF !VerificarPermissao()
		lSegue  := .F.
	ENDIF

	IF lSegue .And. !ExistDir("C:\Coletor")
		IF MakeDir("C:\Coletor",NIL,.F.) != 0
			lSegue  := .F.
			MsgStop('Erro ao tentar criar a pasta C:\Coletor no computador: ' + cValToChar(FError()), "ATFA999")
		ENDIF
	ENDIF

	IF lSegue .And. !_INCLUIR
		cExt := "Arquivo CSV | " + ZZX->ZZX_FILIAL + "*.CSV"
	ENDIF

	IF lSegue .And. Empty(cPath := cGetFile(cExt,'Importar Inventário',1,'C:\Coletor',.T.,,.F.))
		lSegue  :=  .F.
		MsgAlert("Arquivo não informado!","ATFA999")
	ENDIF

	cPath := UPPER(cPath)

	IF lSegue .And. !File(cPath)
		lSegue  :=  .F.
		MsgAlert("O arquivo " +cPath + " não foi encontrado!","ATFA999")
	ENDIF

	If lSegue

		IF _INCLUIR
			_MENSAGEM := "Confirma a importação do arquivo selecionado para incluir um novo inventário?"
		ELSE
			_MENSAGEM := "Confirma a importação do arquivo selecionado para alterar o inventário?" + CRLF +;
			"Filial: " + ZZX->ZZX_FILIAL + CRLF +;
			"Inventário: " + ZZX->ZZX_INVENT + CRLF +;
			"Data: " + DtoC(ZZX->ZZX_DATA) + CRLF +;
			"Descrição: " + ZZX->ZZX_DESCRI + CRLF +;
			"Status: " + ZZX->ZZX_STATUS
		ENDIF

		IF ApMsgYesNo(_MENSAGEM + CRLF + CRLF + cPath,"ATFA999")
			FT_FUSE(cPath)

			ProcRegua(FT_FLASTREC())
			FT_FGOTOP()

			WHILE !FT_FEOF()

				IncProc("Lendo arquivo...")

				cLinha := FT_FREADLN()

				nLinha += 1

				IF lPrim
					aCampos := Separa(cLinha,";",.T.)
					lPrim := .F.

					IF LEN(aCampos) != 11
						FT_FUSE()
						lSegue := .F.
						MsgAlert("Verique a estrutura do arquivo que está sendo importado, deve conter 11 colunas!", "ATFA999")
						Exit
					ENDIF
				ELSE
					AADD(aDados,Separa(STRTRAN(cLinha,"NULL",""),";",.T.))

					IF LEN(aDados[nLinha - 1]) != 11
						FT_FUSE()
						lSegue :=  .F.
						MsgAlert("Verique a estrutura do arquivo que está sendo importado, linha: " + ALLTRIM(STR(nLinha)) + "." + CRLF + CRLF + cLinha, "ATFA999")
						Exit
					ENDIF
				ENDIF

				FT_FSKIP()
			ENDDO

			If lSegue

				cArq := SUBSTR(cPath,LEN(cPath)-27,28)

				IF SUBSTR(cArq,1,8) != aDados[1,6]
					FT_FUSE()
					lSegue := .F.
					MsgAlert("A filial do arquivo de inventário " + SUBSTR(cArq,1,8) + " é diferente da filial do inventário " + aDados[1,6]  + ".", "ATFA999")
				ENDIF

				IF lSegue .And. POSICIONE('ZZY',2,aDados[1,6]+cArq,'ZZY_ARQUIVO') == cArq
					FT_FUSE()
					lSegue := .F.
					MsgAlert("O arquivo " + cArq + " de inventário já foi importado!", "ATFA999")
				ENDIF

				IF lSegue

					IF _INCLUIR
						IF POSICIONE('ZZX',3,aDados[1,6]+'ABERTO                   ','ZZX_STATUS') == 'ABERTO                   '
							FT_FUSE()
							lSegue := .F.
							MsgAlert("Já existe um inventário com status aberto para essa filial " + aDados[1,6] + ".", "ATFA999")
						ENDIF
					ELSE
						IF ZZX->ZZX_STATUS != 'ABERTO'
							FT_FUSE()
							lSegue := .F.
							MsgAlert("Somente inventário com status aberto pode ser alterado!", "ATFA999")
						ENDIF

						IF lSegue .And. ZZX->ZZX_FILIAL != aDados[1,6]
							FT_FUSE()
							lSegue := .F.
							MsgAlert("A filial do arquivo de inventário " + aDados[1,6] + " é diferente da filial do inventário em aberto " + ZZX->ZZX_FILIAL + ".", "ATFA999")
						ENDIF
					ENDIF

					IF lSegue

						_CODIGO := GerarCodigo(aDados[1,6])

						BEGIN Transaction

							IF _INCLUIR

								IF SUBSTR(aDados[1,6],5,4) == '0001'
									_AUX := ''

									IF !EMPTY(aDados[1,7])
										_AUX := ALLTRIM(POSICIONE('SNL',1,xFILIAL('SNL')+aDados[1,7],'NL_DESCRIC'))

										IF EMPTY(_AUX) .AND. !EMPTY(aDados[1,8])
											_AUX := ALLTRIM(POSICIONE('RD0',1,xFILIAL('RD0')+aDados[1,8],'RD0_NOME'))
										ENDIF

										IF !EMPTY(_AUX)
											_AUX := ' | ' + _AUX
										ENDIF
									ENDIF

									IF !EMPTY(_AUX)
										_AUX := SUBSTR(DTOC(DATE()) + ' | ' + ALLTRIM(FWFilialName('01',aDados[1,6])) + _AUX, 1, 100)
									ELSE
										_AUX := DTOC(DATE()) + ' | ' + FWFilialName('01',aDados[1,6])
									ENDIF
								ELSE
									_AUX := DTOC(DATE()) + ' | ' + FWFilialName('01',aDados[1,6])
								ENDIF

								RecLock("ZZX",.T.)
								ZZX->ZZX_FILIAL := aDados[1,6]
								ZZX->ZZX_INVENT := _CODIGO
								ZZX->ZZX_DATA   := _DATA
								ZZX->ZZX_DESCRI := _AUX
								ZZX->ZZX_USUINV := RetCodUsr()
								ZZX->ZZX_STATUS := 'ABERTO'
								ZZX->(MsUnlock())
							ELSE
								_CODIGO := ZZX->ZZX_INVENT
							ENDIF

							ProcRegua(Len(aDados))
							FOR I := 1 TO LEN(aDados)

								IncProc("Importando dados: " + aDados[I,2])

								IF EMPTY(POSICIONE('ZZY',3,ZZX->ZZX_FILIAL+ZZX->ZZX_INVENT+aDados[I,2],'ZZY_FILIAL')) .OR. !EMPTY(POSICIONE('ZZY',3,ZZX->ZZX_FILIAL+ZZX->ZZX_INVENT+aDados[I,2],'ZZY_FILINV'))
									RecLock("ZZY",.T.)
									ZZY->ZZY_FILIAL := ZZX->ZZX_FILIAL
									ZZY->ZZY_INVENT := ZZX->ZZX_INVENT
									ZZY->ZZY_FILINV := aDados[I,6]
									ZZY->ZZY_LOCINV := aDados[I,7]
									ZZY->ZZY_RESINV := aDados[I,8]
									ZZY->ZZY_FILATI := aDados[I,1]
									ZZY->ZZY_CODATI := aDados[I,2]
									ZZY->ZZY_DESATI := aDados[I,3]
									ZZY->ZZY_LOCATI := aDados[I,4]
									ZZY->ZZY_RESATI := aDados[I,5]
									IF !EMPTY(aDados[I,9])
										ZZY->ZZY_BAIATI := CtoD(aDados[I,9])
									ENDIF
									ZZY->ZZY_SITUAC := aDados[I,11]
									ZZY->ZZY_USUINV := RetCodUsr()
									ZZY->ZZY_DATIMP := _DATA
									ZZY->ZZY_HORIMP := _HORA
									ZZY->ZZY_ARQUIV := cArq
									ZZY->(MsUnlock())
								ELSE
									RecLock("ZZY",.F.)
									ZZY->ZZY_FILINV := aDados[I,6]
									ZZY->ZZY_LOCINV := aDados[I,7]
									ZZY->ZZY_RESINV := aDados[I,8]
									ZZY->ZZY_SITUAC := aDados[I,11]
									ZZY->ZZY_USUINV := RetCodUsr()
									ZZY->ZZY_DATIMP := _DATA
									ZZY->ZZY_HORIMP := _HORA
									ZZY->ZZY_ARQUIV := cArq
									ZZY->(MsUnlock())
								ENDIF
							NEXT I

							FT_FUSE()

							IF !CpyT2S( cPath, '\inventario')
								DisarmTransaction()
								lSegue := .F.
								MsgStop('Erro ao tentar copiar o arquivo importado para o servidor!', "ATFA999")
							ENDIF

							nRetorno := FRENAME(cPath , SUBSTR(cPath,1,LEN(cPath)-4) + '.IMP')
							IF lSegue .And. nRetorno == -1
								DisarmTransaction()
								lSegue := .F.
								MsgStop('Erro ao tentar alterar o nome do arquivo importado: ' + STR(FError(),4), "ATFA999")
							ENDIF

						END Transaction

						If lSegue

							TCSPEXEC('SP_ATFA999_INC', ZZX->ZZX_FILIAL, ZZX->ZZX_INVENT)

							MsgInfo(ALLTRIM(STR(I - 1)) + " registros importados com sucesso!" + CRLF + CRLF + "Tempo: " + ELAPTIME(_HORA, TIME()), "ATFA999")

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	End If

Return NIL

/*/================================================================================================================================/*/
/*/{Protheus.doc} GerarCodigo
Gera o Código do inventário.

@type function
@author Thiago Rasmussen
@since 17/04/2018
@version P12.1.23

@param _FILIAL, Caractere, Filial do inventário.

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Código do Inventário.

/*/
/*/================================================================================================================================/*/

Static Function GerarCodigo(_FILIAL)
	Local _SQL    := ""
	Local _ALIAS  := GetNextAlias()
	Local _CODIGO := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_SQL := "SELECT ISNULL(MAX(ZZX_INVENT),'000000') AS ZZX_INVENT FROM ZZX010 WITH (NOLOCK) WHERE ZZX_FILIAL = '" + _FILIAL + "'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.T.)

	_CODIGO := SOMA1((_ALIAS )->ZZX_INVENT)

	(_ALIAS)->(dbCloseArea())

Return _CODIGO

/*/================================================================================================================================/*/
/*/{Protheus.doc} ImprimirInventario
Imprime Inventário em Excel.

@type function
@author Thiago Rasmussen
@since 17/04/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ImprimirInventario()
	Local _SQL     := ""
	Local _FILE    := "ATFA999__" + ZZX->ZZX_INVENT + "__" + DTOS(DATE()) + "__" + SUBSTR(TIME(),1,2) + "_" + SUBSTR(TIME(),4,2) + "_" + SUBSTR(TIME(),7,2) + ".XML"
	Local lSegue   := .T.

	Private oExcel := FWMSEXCEL():New()
	Private _ALIAS := GetNextAlias()

	//IF Pergunte("ATFA999", .T.) == .F.
	//	Return	//
	//ENDIF

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF !ExistDir("C:\TEMP")
		IF MakeDir("C:\TEMP",NIL,.F.) != 0
			lSegue   := .F.
			MsgStop('Erro ao tentar criar a pasta C:\TEMP no computador: ' + cValToChar(FError()), "ATFA999")
		ENDIF
	ENDIF

	If lSegue

		_SQL := "EXEC SP_ATFA999_R01 '" + ZZX->ZZX_FILIAL + "', '" + ZZX->ZZX_INVENT + "'"

		IF SELECT(_ALIAS) > 0
			dbSelectArea(_ALIAS)
			_ALIAS->(dbCloseArea())
		ENDIF

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)

		DbSelectArea(_ALIAS)
		_ALIAS->(dbGotop())

		ProcessarPlanilha()

		(_ALIAS)->(dbCloseArea())

		oExcel:AddworkSheet("Parâmetros da Impressão")
		oExcel:AddTable ("Parâmetros da Impressão","Parâmetros da Impressão")
		oExcel:AddColumn("Parâmetros da Impressão","Parâmetros da Impressão","===================================================================",1,1,.F.)
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Filial: " + ZZX->ZZX_FILIAL})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Inventário: " + ZZX->ZZX_INVENT + " - " + ZZX->ZZX_DESCRI})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Data: " + DTOC(ZZX->ZZX_DATA)})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Status: " + ZZX->ZZX_STATUS})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Usuário: " + UsrFullName(__cUserID)})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Impressão: " + DTOC(DATE()) + " - " + TIME()})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Computador: " + GetComputerName()})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"IP: " + GetClientIP()})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Usuário Sistema Operacional: " + LogUserName()})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Servidor: " + GetServerIP()})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Ambiente: " + GetEnvServer()})

		oExcel:SetFontSize(10)
		oExcel:SetFont("Times New Roman")
		oExcel:Activate()

		oExcel:GetXMLFile("C:\TEMP\" + _FILE)

		IF ShellExecute("Open", "Excel", _FILE, "C:\TEMP\", 1 ) <= 32
			MsgAlert("Microsoft Excel não instalado, arquivo foi gerado no seguinte diretório: " + CRLF + CRLF + "C:\TEMP\" + _FILE,"ATFA999")
		ENDIF

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ProcessarPlanilha
Gera as linhas da planilha com os dados do inventário.

@type function
@author Thiago Rasmussen
@since 17/04/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function ProcessarPlanilha()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oExcel:AddworkSheet("Inventário")
	oExcel:AddTable ("Inventário","Inventário")
	oExcel:AddColumn("Inventário","Inventário","Situação",1,1,.F.)
	oExcel:AddColumn("Inventário","Inventário","Filial Inventário",1,1,.F.)
	oExcel:AddColumn("Inventário","Inventário","Local Inventário",1,1,.F.)
	oExcel:AddColumn("Inventário","Inventário","Responsável Inventário",1,1,.F.)
	oExcel:AddColumn("Inventário","Inventário","Filial Ativo",1,1,.F.)
	oExcel:AddColumn("Inventário","Inventário","Ativo",1,1,.F.)
	oExcel:AddColumn("Inventário","Inventário","Local Ativo",1,1,.F.)
	oExcel:AddColumn("Inventário","Inventário","Responsável Ativo",1,1,.F.)
	oExcel:AddColumn("Inventário","Inventário","Data Baixa",1,1,.F.)

	WHILE !(_ALIAS)->(EOF())
		oExcel:AddRow("Inventário","Inventário",{ ;
		(_ALIAS)->ZZY_SITUAC, ;
		(_ALIAS)->ZZY_FILINV, ;
		(_ALIAS)->ZZY_LOCINV, ;
		(_ALIAS)->ZZY_RESINV, ;
		(_ALIAS)->ZZY_FILATI, ;
		(_ALIAS)->ZZY_CODATI, ;
		(_ALIAS)->ZZY_LOCATI, ;
		(_ALIAS)->ZZY_RESATI, ;
		(_ALIAS)->ZZY_BAIATI;
		})

		(_ALIAS)->(dbSkip())
	END

Return NIL



/*/================================================================================================================================/*/
/*/{Protheus.doc} VerificarPermissao
Verifica permissão do usuário para executar.

@type function
@author Thiago Rasmussen
@since 17/04/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo verdadeiro.

/*/
/*/================================================================================================================================/*/

Static Function VerificarPermissao()

	Local lRet := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF !(RetCodUsr() $(_MV_XUSUINV))
		MsgAlert("Usuário não possue permissão para executar essa opção!","ATFA999")
		lRet := .F.
	ENDIF

Return lRet