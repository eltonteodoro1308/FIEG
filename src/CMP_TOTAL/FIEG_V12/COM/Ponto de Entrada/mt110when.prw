#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110WHEN
Ponto de Entrada para liberar sempre a digitacao do campo Centro de Custos na Solicitacao de Compras.

@type function
@author FIEG
@since 07/12/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna Verdadeiro se conte�do do parametro MV_PCFILEN for Falso.
/*/
/*/================================================================================================================================/*/

User Function MT110WHEN()

Local lRet := SuperGetMv("MV_PCFILEN")

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If !lRet
	lRet := .T.
Endif	

Return lRet
