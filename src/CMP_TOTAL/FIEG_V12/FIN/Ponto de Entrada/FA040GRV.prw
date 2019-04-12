#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
P.E. executado após a gravação da contabilização, no qual realiza o tratamento da numeração automática dos títulos de contas a receber.

@type function
@author Fábrica DOIT SP
@since 24/06/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User function FA040GRV()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If !lF040Auto .and. (__lSX8) .and. Alltrim(M->E1_TIPO) <> "NF"
	ConfirmSX8()
EndIf

Return
