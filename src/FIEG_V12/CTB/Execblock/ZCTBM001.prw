#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ZCTBM001
Gerar arquivo contábil de integração para CNI.

@type function
@author Thiago Rasmussen
@since 17/09/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ZCTBM001()
	Local _SQL     := ""
	Local lSegue   := .T.
	Private oExcel := FWMSEXCEL():New()
	Private _ALIAS := GetNextAlias()
	Private _FILE  := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If PERGUNTE("ZCTBM001", .T.) == .F.
		lSegue := .F. //Return
	EndIf

	If lSegue

		_FILE  := ALLTRIM(xFILIAL("CT1")) + "_" + SUBSTR(DTOS(MV_PAR02),5,2) + "_" + SUBSTR(DTOS(MV_PAR02),1,4) + "__" + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + SUBSTR(TIME(),7,2)

		If !ExistDir("C:\TEMP")
			If MakeDir("C:\TEMP",NIL,.F.) != 0
				lSegue := .F. //Return MsgStop('Erro ao tentar criar a pasta C:\TEMP no computador: ' + cValToChar(FError()), "ZCTBM001")
			EndIf
		EndIf

		If lSegue

			_SQL := "EXEC SP_ZCTBM001 '" + xFILIAL("CT1") + "','" + DTOS(MV_PAR01) + "','" + DTOS(MV_PAR02) + "','" + ALLTRIM(MV_PAR03) + "','" + ALLTRIM(MV_PAR04) + "'," + cValToChar(MV_PAR05) + "," + cValToChar(MV_PAR06)

			If SELECT(_ALIAS) > 0
				dbSelectArea(_ALIAS)
				(_ALIAS)->(dbCloseArea())
			EndIf

			FWMsgRun(,{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Consultando Saldo Contábil","Aguarde..")

			DbSelectArea(_ALIAS)
			(_ALIAS)->(dbGotop())

			FWMsgRun(,{|| ProcessarPlanilha()},"Processando Relatório","Aguarde..")

			(_ALIAS)->(dbCloseArea())

			oExcel:AddworkSheet("Parâmetros da Impressão")
			oExcel:AddTable ("Parâmetros da Impressão","Parâmetros da Impressão")
			oExcel:AddColumn("Parâmetros da Impressão","Parâmetros da Impressão","===================================================================",1,1,.F.)
			oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Filial: " + xFILIAL("CT1")})
			oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Período: " + DTOC(MV_PAR01) + " à " + DTOC(MV_PAR02)})
			oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Conta: " + ALLTRIM(MV_PAR03) + " à " + ALLTRIM(MV_PAR04)})
			oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Usuário: " + UsrFullName(__cUserID)})
			oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Impressão: " + DTOC(DATE()) + " - " + TIME()})
			oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Computador: " + GetComputerName()})
			oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"IP: " + GetClientIP()})
			oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Usuário Sistema Operacional: " + LogUserName()})
			oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Servidor: " + GetServerIP()})
			oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Ambiente: " + GetEnvServer()})

			oExcel:SetFontSize(11)
			oExcel:SetFont("Calibri Light")
			oExcel:Activate()

			FWMsgRun(, {|| oExcel:GetXMLFile("C:\TEMP\" + _FILE + ".XML")},"Gerando Relatório", "Aguarde..")

			If ShellExecute("Open", "Excel", _FILE + ".XML", "C:\TEMP\", 1 ) <= 32
				MsgAlert("Microsoft Excel não instalado, arquivo foi gerado no seguinte diretório: " + CRLF + CRLF + "C:\TEMP\" + _FILE + ".XML","ZCTBM001")
			EndIf

		EndIf

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ProcessarPlanilha
Gerar arquivo contábil de integração para CNI. Function processada pela function ZCTBM001

@type function
@author Thiago Rasmussen
@since 17/09/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function ProcessarPlanilha()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oExcel:AddworkSheet("Integração Contábil CNI")
	oExcel:AddTable ("Integração Contábil CNI","Integração Contábil CNI")
	oExcel:AddColumn("Integração Contábil CNI","Integração Contábil CNI","Filial",1,1,.F.)
	oExcel:AddColumn("Integração Contábil CNI","Integração Contábil CNI","Conta",1,1,.F.)
	oExcel:AddColumn("Integração Contábil CNI","Integração Contábil CNI","Descrição",1,1,.F.)
	oExcel:AddColumn("Integração Contábil CNI","Integração Contábil CNI","Superior",1,1,.F.)
	oExcel:AddColumn("Integração Contábil CNI","Integração Contábil CNI","Saldo Anterior",3,3,.F.)
	oExcel:AddColumn("Integração Contábil CNI","Integração Contábil CNI","Débito",3,3,.F.)
	oExcel:AddColumn("Integração Contábil CNI","Integração Contábil CNI","Crédito",3,3,.F.)
	oExcel:AddColumn("Integração Contábil CNI","Integração Contábil CNI","Saldo Atual",3,3,.F.)

	nArquivo := fcreate("C:\TEMP\" + _FILE + ".CSV", FC_NORMAL)

	While !(_ALIAS)->(EOF())
		oExcel:AddRow("Integração Contábil CNI","Integração Contábil CNI",{ ;
		xFILIAL("CT1"), ;
		(_ALIAS)->CONTA, ;
		(_ALIAS)->DESCCTA, ;
		(_ALIAS)->SUPERIOR, ;
		(_ALIAS)->SALDO_ANTERIOR, ;
		(_ALIAS)->DEBITO, ;
		(_ALIAS)->CREDITO, ;
		(_ALIAS)->SALDO_ATUAL;
		})

		fwrite(nArquivo, ALLTRIM((_ALIAS)->ARQUIVO) + ';' + CRLF)

		(_ALIAS)->(dbSkip())
	End

	fclose(nArquivo)

	ShellExecute( "Open", "notepad.exe", _FILE + ".CSV", "C:\TEMP\", 1 ) //<= 32

Return