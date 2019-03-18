#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LPIMPCC
Gravar o campo do centro de custo para a retenção de impostos.

@type function
@author Thiago Rasmussen
@since 11/08/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Código do Centro de Custo.

/*/
/*/================================================================================================================================/*/

User Function LPIMPCC()
	Local aArea       := GetArea()
	Local _cCC        := ""
	Local _cQry       := ""
	
	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQry := " SELECT CC_IMPOSTO FROM SIGAMAT "
	_cQry += " WHERE FILIAL='"+SM0->M0_CODFIL+"' "

	If Select("QRY") > 0
		DbSelectArea("QRY")
		QRY->(DbCloseArea())
	EndIf

	_cQry := ChangeQuery(_cQry)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), 'QRY', .F., .T.)

	DbSelectArea("QRY")
	QRY->(DbGotop())

	IF QRY->(!EOF())
		_cCC := CC_IMPOSTO
	ENDIF


	DbCloseArea()
	RestArea(aArea)

Return(_cCC)

/*/================================================================================================================================/*/
/*/{Protheus.doc} LPIMPCCV
Funcao para controle de versao.

@type function
@author Thiago Rasmussen
@since 02/09/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Versão.

/*/
/*/================================================================================================================================/*/

User Function LPIMPCCV()

	Local cRet  := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cRet := "20140902001"

Return (cRet)