#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} COMR010
Relatório de acompanhamento de processos de compra.

@type function
@author Thiago Rasmussen
@since 10/11/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function COMR010()
	Local _SQL     := ""
	Local _FILE    := "COMR010__" + DTOS(DATE()) + "__" + SUBSTR(TIME(),1,2) + "_" + SUBSTR(TIME(),4,2) + "_" + SUBSTR(TIME(),7,2) + ".XML"
	Private oExcel := FWMSEXCEL():New()
	Private _ALIAS := GetNextAlias()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF Pergunte("COMR010", .T.) == .F.
		Return
	ENDIF

	_SQL := "EXEC SP_COMR010 '" + MV_PAR01 + "','" + MV_PAR02 + "','" + DTOS(MV_PAR03) + "','" + DTOS(MV_PAR04) + "'"

	IF SELECT(_ALIAS) > 0
		dbSelectArea(_ALIAS)
		(_ALIAS)->(dbCloseArea())
	ENDIF

	FWMsgRun(,{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Consultando Processos de Compra","Aguarde..")

	DbSelectArea(_ALIAS)
	(_ALIAS)->(dbGotop())

	FWMsgRun(,{|| ProcessarPlanilha()},"Processando Relatório","Aguarde..")

	(_ALIAS)->(dbCloseArea())

	oExcel:AddworkSheet("Parâmetros da Impressão")
	oExcel:AddTable ("Parâmetros da Impressão","Parâmetros da Impressão")
	oExcel:AddColumn("Parâmetros da Impressão","Parâmetros da Impressão","===================================================================",1,1,.F.)
	oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Filial: " + MV_PAR01 + " à " + MV_PAR02})
	oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Período de emissão da solicitação: " + DTOC(MV_PAR03) + " à " + DTOC(MV_PAR04)})
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

	FWMsgRun(, {|| oExcel:GetXMLFile("C:\" + _FILE)},"Gerando Relatório", "Aguarde..")

	IF ShellExecute("Open", "Excel", _FILE, "C:\", 1 ) <= 32
		MsgAlert("Microsoft Excel não instalado, arquivo foi gerado no seguinte diretório: " + CRLF + CRLF + "C:\" + _FILE,"COMR010")
	ENDIF

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ProcessarPlanilha
Processando Relatório.

@type function
@author Thiago Rasmussen
@since 10/11/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ProcessarPlanilha()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oExcel:AddworkSheet("Processos de Compra")
	oExcel:AddTable ("Processos de Compra","Processos de Compra")
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Filial",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Solicitação",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Item",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Produto",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Emissão",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Total",3,3,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Comprador",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Aprovador",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Data",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Cotação",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Emissão",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Fornecedor",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Pedido",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Emissão",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Contrato",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Vigência",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Tipo",1,1,.F.)

	WHILE !(_ALIAS)->(EOF())
		oExcel:AddRow("Processos de Compra","Processos de Compra",{ ;
		(_ALIAS)->C1_FILIAL, ;
		(_ALIAS)->C1_NUM, ;
		(_ALIAS)->C1_ITEM, ;
		(_ALIAS)->C1_PRODUTO, ;
		(_ALIAS)->C1_EMISSAO, ;
		(_ALIAS)->C1_TOTAL, ;
		(_ALIAS)->C1_COMPRADOR, ;
		(_ALIAS)->CR_APROVADOR, ;
		(_ALIAS)->CR_EMISSAO, ;
		(_ALIAS)->C8_COTACAO, ;
		(_ALIAS)->C8_EMISSAO, ;
		(_ALIAS)->C8_FORNECE, ;
		(_ALIAS)->C7_PEDIDO, ;
		(_ALIAS)->C7_EMISSAO, ;
		(_ALIAS)->CN9_CONTRATO, ;
		(_ALIAS)->CN9_VIGENCIA, ;
		(_ALIAS)->TIPO ;
		})

		(_ALIAS)->(dbSkip())
	END

Return