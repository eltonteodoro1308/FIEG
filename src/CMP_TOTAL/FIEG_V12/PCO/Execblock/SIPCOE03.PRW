#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOE03
Tratamento do campo valor da contingencia - Lacto 000356/02.

@type function
@author TOTVS
@since 08/06/12
@version P12.1.23

@param _nPar, Numérico, Informe a descrição do 1º parêmtro.

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Numérico, Valor usado no lançamento do PCO.
/*/
/*/================================================================================================================================/*/

User Function SIPCOE03(_nPar)

Local _nRet := _nPar

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If Type("_NPERCEMP") == "N" .and. _NPERCEMP <> 0
	_nRet := _nRet * (_NPERCEMP/100)
EndIf

Return(_nRet)
