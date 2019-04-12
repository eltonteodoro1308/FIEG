#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} GCP02MOD
Retorno da modalidade.

@type function
@author Thiago Rasmussen
@since 19/08/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Código da Modalidade.

/*/
/*/================================================================================================================================/*/

User Function GCP02MOD()

	Local _cMod := Alltrim(PARAMIXB[1])
	Local _cRet

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	U_SICOMA28(_cMod,"E")

	_cRet:=	M->CO1_MODALI

Return _cRet