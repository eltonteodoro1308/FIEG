#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} COMR010
Relat�rio de acompanhamento de processos de compra.

@type function
@author Thiago Rasmussen
@since 10/11/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function COMR010()
	Local _SQL     := ""
	Local _FILE    := "COMR010__" + DTOS(DATE()) + "__" + SUBSTR(TIME(),1,2) + "_" + SUBSTR(TIME(),4,2) + "_" + SUBSTR(TIME(),7,2) + ".XML"
	Private oExcel := FWMSEXCEL():New()
	Private _ALIAS := GetNextAlias()

	//--< Log das Personaliza��es >-----------------------------
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

	FWMsgRun(,{|| ProcessarPlanilha()},"Processando Relat�rio","Aguarde..")

	(_ALIAS)->(dbCloseArea())

	oExcel:AddworkSheet("Par�metros da Impress�o")
	oExcel:AddTable ("Par�metros da Impress�o","Par�metros da Impress�o")
	oExcel:AddColumn("Par�metros da Impress�o","Par�metros da Impress�o","===================================================================",1,1,.F.)
	oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Filial: " + MV_PAR01 + " � " + MV_PAR02})
	oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Per�odo de emiss�o da solicita��o: " + DTOC(MV_PAR03) + " � " + DTOC(MV_PAR04)})
	oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Usu�rio: " + UsrFullName(__cUserID)})
	oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Impress�o: " + DTOC(DATE()) + " - " + TIME()})
	oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Computador: " + GetComputerName()})
	oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"IP: " + GetClientIP()})
	oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Usu�rio Sistema Operacional: " + LogUserName()})
	oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Servidor: " + GetServerIP()})
	oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Ambiente: " + GetEnvServer()})

	oExcel:SetFontSize(10)
	oExcel:SetFont("Times New Roman")
	oExcel:Activate()

	FWMsgRun(, {|| oExcel:GetXMLFile("C:\" + _FILE)},"Gerando Relat�rio", "Aguarde..")

	IF ShellExecute("Open", "Excel", _FILE, "C:\", 1 ) <= 32
		MsgAlert("Microsoft Excel n�o instalado, arquivo foi gerado no seguinte diret�rio: " + CRLF + CRLF + "C:\" + _FILE,"COMR010")
	ENDIF

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ProcessarPlanilha
Processando Relat�rio.

@type function
@author Thiago Rasmussen
@since 10/11/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ProcessarPlanilha()

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oExcel:AddworkSheet("Processos de Compra")
	oExcel:AddTable ("Processos de Compra","Processos de Compra")
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Filial",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Solicita��o",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Item",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Produto",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Emiss�o",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Total",3,3,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Comprador",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Aprovador",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Data",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Cota��o",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Emiss�o",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Fornecedor",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Pedido",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Emiss�o",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Contrato",1,1,.F.)
	oExcel:AddColumn("Processos de Compra","Processos de Compra","Vig�ncia",1,1,.F.)
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