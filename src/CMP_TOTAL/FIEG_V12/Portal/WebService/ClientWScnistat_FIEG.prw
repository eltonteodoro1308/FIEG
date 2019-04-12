#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*/================================================================================================================================/*/
/*/{Protheus.doc} _DMKHORP
Código-Fonte gerado por ADVPL WSDL Client 1.111215
Alterações neste arquivo podem causar funcionamento incorreto
e serão perdidas caso o código-fonte seja gerado novamente.

@type function
@author Thiago Rasmussen
@since 07/04/12
@version P12.1.23

@obs Projeto ELO
WSDL Location: http://srvhomologa:8185/ws_01go0001/WSCNIESTAT.apw?WSDL

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/


User Function _DMKHORP ; Return  // "dummy" function - Internal Use

/* -------------------------------------------------------------------------------
WSDL Service WSWSCNIESTAT
------------------------------------------------------------------------------- */

WSCLIENT WSWSCNIESTAT

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETSTATUSBUT
	WSMETHOD PUTESTATUS

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCPEDIDO                  AS string
	WSDATA   cGETSTATUSBUTRESULT       AS string
	WSDATA   cPUTESTATUSRESULT         AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSCNIESTAT
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120314] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSCNIESTAT
Return

WSMETHOD RESET WSCLIENT WSWSCNIESTAT
	::cCPEDIDO           := NIL
	::cGETSTATUSBUTRESULT := NIL
	::cPUTESTATUSRESULT  := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSCNIESTAT
Local oClone := WSWSCNIESTAT():New()
	oClone:_URL          := ::_URL
	oClone:cCPEDIDO      := ::cCPEDIDO
	oClone:cGETSTATUSBUTRESULT := ::cGETSTATUSBUTRESULT
	oClone:cPUTESTATUSRESULT := ::cPUTESTATUSRESULT
Return oClone

// WSDL Method GETSTATUSBUT of Service WSWSCNIESTAT

WSMETHOD GETSTATUSBUT WSSEND cCPEDIDO WSRECEIVE cGETSTATUSBUTRESULT WSCLIENT WSWSCNIESTAT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETSTATUSBUT xmlns="http://srvhomologa:8185/">'
cSoap += WSSoapValue("CPEDIDO", ::cCPEDIDO, cCPEDIDO , "string", .T. , .F., 0 , NIL, .F.)
cSoap += "</GETSTATUSBUT>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"http://srvhomologa:8185/GETSTATUSBUT",;
	"DOCUMENT","http://srvhomologa:8185/",,"1.031217",;
	"http://srvhomologa:8185/ws_01go0001/WSCNIESTAT.apw")

::Init()
::cGETSTATUSBUTRESULT :=  WSAdvValue( oXmlRet,"_GETSTATUSBUTRESPONSE:_GETSTATUSBUTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTESTATUS of Service WSWSCNIESTAT

WSMETHOD PUTESTATUS WSSEND cCPEDIDO WSRECEIVE cPUTESTATUSRESULT WSCLIENT WSWSCNIESTAT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTESTATUS xmlns="http://srvhomologa:8185/">'
cSoap += WSSoapValue("CPEDIDO", ::cCPEDIDO, cCPEDIDO , "string", .T. , .F., 0 , NIL, .F.)
cSoap += "</PUTESTATUS>"

oXmlRet := SvcSoapCall(	Self,cSoap,;
	"http://srvhomologa:8185/PUTESTATUS",;
	"DOCUMENT","http://srvhomologa:8185/",,"1.031217",;
	"http://srvhomologa:8185/ws_01go0001/WSCNIESTAT.apw")

::Init()
::cPUTESTATUSRESULT  :=  WSAdvValue( oXmlRet,"_PUTESTATUSRESPONSE:_PUTESTATUSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL)

END WSMETHOD

oXmlRet := NIL
Return .T.