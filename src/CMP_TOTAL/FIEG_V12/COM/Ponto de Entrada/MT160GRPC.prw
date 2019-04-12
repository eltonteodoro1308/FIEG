#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
Descri��o detalhada da fun��o.

@type function
@author TOTVS
@since 25/05/2012
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Nil, Fun��o sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT160GRPC()

//Local _aSC8 := PARAMIXB[2]

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
SC7->C7_NUMPR 	:= SC8->C8_NPROC

Return()
