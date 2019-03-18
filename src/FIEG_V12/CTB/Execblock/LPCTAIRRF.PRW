#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LPCTAIRRF
Gravar a conta contabil do IRRF de acordo com o codigo de retencao do Imposto.

@type function
@author Thiago Rasmussen
@since 12/08/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Número da Conta.

/*/
/*/================================================================================================================================/*/

User Function LPCTAIRRF()
	Local _cCTA        := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	
	_cCTA := IIF(cCodRet=="0588",21010301002,IIF(cCodRet=="1708",21010301003,IIF(cCodRet=="3280",21010301004,"")))

Return(_cCTA)

/*/================================================================================================================================/*/
/*/{Protheus.doc} LPCTAIRV
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

User Function LPCTAIRV()

	Local cRet  := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cRet := "20140902001"

Return (cRet)