#include "protheus.ch"

// Autor....: Thiago Rasmussen
// Data.....: 21/07/2014
// Modulo...: 01 - Ativo
// Descri��o: Valida��es ao realizar uma transfer�ncia de ativo.
#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} AF060TOK
Valida��es ao realizar uma transfer�ncia de ativo.

@type function
@author Thiago Rasmussen
@since 21/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Nil, Fun��o sem retorno.

/*/
/*/================================================================================================================================/*/

User Function AF060TOK()

	Local _cEmpOri    := SubStr(PARAMIXB[2],1,2)
	Local _cEmpDest   := SubStr(PARAMIXB[1],1,2)
	Local _MV_ATFBLQM := SuperGetMV("MV_ATFBLQM")
	Local lRet        := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF _cEmpOri <> _cEmpDest
		MsgAlert("N�o � permitido transfer�ncia entre empresas diferentes." + CRLF + CRLF +;
		"Empresa Origem: " + FWCompanyName('01',PARAMIXB[2]) + CRLF +;
		"Empresa Destino: " + FWCompanyName('01',PARAMIXB[1]),"AF060TOK")
		lRet := .F. //RETURN .F.
	ENDIF

	IF lRet .And. dDataBase <= _MV_ATFBLQM
		MsgAlert("N�o � permitido transfer�ncia com database menor ou igual a data de bloqueio para movimenta��o de ativos " + DTOC(_MV_ATFBLQM) + ".","AF060TOK")
		lRet := .F. //RETURN .F.
	ENDIF

RETURN lRet