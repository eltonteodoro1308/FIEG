#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ZCTBM001
Gerar arquivo cont�bil de integra��o para CNI.

@type function
@author Thiago Rasmussen
@since 17/09/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ZCTBM001()
	Local _SQL     := ""
	Local lSegue   := .T.
	Private oExcel := FWMSEXCEL():New()
	Private _ALIAS := GetNextAlias()
	Private _FILE  := ""

	//--< Log das Personaliza��es >-----------------------------
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

			FWMsgRun(,{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Consultando Saldo Cont�bil","Aguarde..")

			DbSelectArea(_ALIAS)
			(_ALIAS)->(dbGotop())

			FWMsgRun(,{|| ProcessarPlanilha()},"Processando Relat�rio","Aguarde..")

			(_ALIAS)->(dbCloseArea())

			oExcel:AddworkSheet("Par�metros da Impress�o")
			oExcel:AddTable ("Par�metros da Impress�o","Par�metros da Impress�o")
			oExcel:AddColumn("Par�metros da Impress�o","Par�metros da Impress�o","===================================================================",1,1,.F.)
			oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Filial: " + xFILIAL("CT1")})
			oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Per�odo: " + DTOC(MV_PAR01) + " � " + DTOC(MV_PAR02)})
			oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Conta: " + ALLTRIM(MV_PAR03) + " � " + ALLTRIM(MV_PAR04)})
			oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Usu�rio: " + UsrFullName(__cUserID)})
			oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Impress�o: " + DTOC(DATE()) + " - " + TIME()})
			oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Computador: " + GetComputerName()})
			oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"IP: " + GetClientIP()})
			oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Usu�rio Sistema Operacional: " + LogUserName()})
			oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Servidor: " + GetServerIP()})
			oExcel:AddRow("Par�metros da Impress�o","Par�metros da Impress�o",{"Ambiente: " + GetEnvServer()})

			oExcel:SetFontSize(11)
			oExcel:SetFont("Calibri Light")
			oExcel:Activate()

			FWMsgRun(, {|| oExcel:GetXMLFile("C:\TEMP\" + _FILE + ".XML")},"Gerando Relat�rio", "Aguarde..")

			If ShellExecute("Open", "Excel", _FILE + ".XML", "C:\TEMP\", 1 ) <= 32
				MsgAlert("Microsoft Excel n�o instalado, arquivo foi gerado no seguinte diret�rio: " + CRLF + CRLF + "C:\TEMP\" + _FILE + ".XML","ZCTBM001")
			EndIf

		EndIf

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ProcessarPlanilha
Gerar arquivo cont�bil de integra��o para CNI. Function processada pela function ZCTBM001

@type function
@author Thiago Rasmussen
@since 17/09/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function ProcessarPlanilha()

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oExcel:AddworkSheet("Integra��o Cont�bil CNI")
	oExcel:AddTable ("Integra��o Cont�bil CNI","Integra��o Cont�bil CNI")
	oExcel:AddColumn("Integra��o Cont�bil CNI","Integra��o Cont�bil CNI","Filial",1,1,.F.)
	oExcel:AddColumn("Integra��o Cont�bil CNI","Integra��o Cont�bil CNI","Conta",1,1,.F.)
	oExcel:AddColumn("Integra��o Cont�bil CNI","Integra��o Cont�bil CNI","Descri��o",1,1,.F.)
	oExcel:AddColumn("Integra��o Cont�bil CNI","Integra��o Cont�bil CNI","Superior",1,1,.F.)
	oExcel:AddColumn("Integra��o Cont�bil CNI","Integra��o Cont�bil CNI","Saldo Anterior",3,3,.F.)
	oExcel:AddColumn("Integra��o Cont�bil CNI","Integra��o Cont�bil CNI","D�bito",3,3,.F.)
	oExcel:AddColumn("Integra��o Cont�bil CNI","Integra��o Cont�bil CNI","Cr�dito",3,3,.F.)
	oExcel:AddColumn("Integra��o Cont�bil CNI","Integra��o Cont�bil CNI","Saldo Atual",3,3,.F.)

	nArquivo := fcreate("C:\TEMP\" + _FILE + ".CSV", FC_NORMAL)

	While !(_ALIAS)->(EOF())
		oExcel:AddRow("Integra��o Cont�bil CNI","Integra��o Cont�bil CNI",{ ;
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