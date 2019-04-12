#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOE02
Tratamento do campo valor da SC do lançamento 000051/02.

@type function
@author TOTVS
@since 25/05/12
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Numérico, Valor usado no lançamento do PCO.
/*/
/*/================================================================================================================================/*/

User Function SIPCOE02()

Local _nRet := SC1->(C1_QUANT*C1_VUNIT)  

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If Type("_NPERCEMP") == "N" .and. _NPERCEMP <> 0
	_nRet := _nRet * (_NPERCEMP/100)
EndIf
                      
Return(_nRet)
