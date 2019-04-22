#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT360GRV
PE apos manuten��o de condicao de pagamento.

@type function
@author TOTVS
@since 20/03/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Nil, Fun��o sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT360GRV()

Local _nOpc := IIF(INCLUI,"3",IIF(ALTERA,"4","5"))

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF _nOpc == "5" 							// exclus�o
	SET DELETED OFF							// Considera os registros deletados
ENDIF
                                                
SZZ->(dbSetOrder(1))
IF SZZ->(dbSeek(XFilial("SZZ")+"MATA360"))
	MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA18(_nOpc) } )
ENDIF

SET DELETED ON								// Desconsidera os registros deletados

Return()