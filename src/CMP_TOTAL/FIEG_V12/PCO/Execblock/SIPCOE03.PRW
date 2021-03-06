#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOE03
Tratamento do campo valor da contingencia - Lacto 000356/02.

@type function
@author TOTVS
@since 08/06/12
@version P12.1.23

@param _nPar, Num�rico, Informe a descri��o do 1� par�mtro.

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Num�rico, Valor usado no lan�amento do PCO.
/*/
/*/================================================================================================================================/*/

User Function SIPCOE03(_nPar)

Local _nRet := _nPar

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If Type("_NPERCEMP") == "N" .and. _NPERCEMP <> 0
	_nRet := _nRet * (_NPERCEMP/100)
EndIf

Return(_nRet)
