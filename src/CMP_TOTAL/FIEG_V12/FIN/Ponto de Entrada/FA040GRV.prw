#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
P.E. executado ap�s a grava��o da contabiliza��o, no qual realiza o tratamento da numera��o autom�tica dos t�tulos de contas a receber.

@type function
@author F�brica DOIT SP
@since 24/06/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Nil, Fun��o sem retorno.
/*/
/*/================================================================================================================================/*/

User function FA040GRV()

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If !lF040Auto .and. (__lSX8) .and. Alltrim(M->E1_TIPO) <> "NF"
	ConfirmSX8()
EndIf

Return
