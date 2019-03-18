#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LP650MDAQ
Gravar modalidade de compra do contrato na classe de valor do doc. de entrada.

@type function
@author Wagner Soares
@since 07/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Classe de Valor.

/*/
/*/================================================================================================================================/*/

User Function LP650MDAQ()
	Local aArea       := GetArea()
	Local _cPed       := SD1->D1_PEDIDO
	Local _cCLVL      := ""
	//Local _cNumCtrRev := ""
	Local _cQry       := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQry := " SELECT CN9_XMDAQU FROM "+RETSQLNAME("CN9")
	_cQry += " INNER JOIN "+RETSQLNAME("SC7")+" ON C7_FILIAL=CN9_FILIAL AND C7_CONTRA=CN9_NUMERO AND CN9_REVISA=C7_CONTREV "
	_cQry += " WHERE C7_FILIAL='"+SD1->D1_FILIAL+"' AND C7_NUM='"+_cPed+"'

	If Select("QRY") > 0
		DbSelectArea("QRY")
		QRY->(DbCloseArea())
	EndIf

	_cQry := ChangeQuery(_cQry)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQry), 'QRY', .F., .T.)

	DbSelectArea("QRY")
	QRY->(DbGotop())

	IF QRY->(!EOF())
		_cCLVL := CN9_XMDAQU
	ENDIF


	QRY->(DbCloseArea())
	RestArea(aArea)

Return(_cCLVL)

/*/================================================================================================================================/*/
/*/{Protheus.doc} LP650MDV
Função criada para controle de versao.

@type function
@author Thiago Rasmussen
@since 02/09/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Versão.

/*/
/*/================================================================================================================================/*/

User Function LP650MDV()

	Local cRet  := ""
	
	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cRet := "20140902001"

Return (cRet)