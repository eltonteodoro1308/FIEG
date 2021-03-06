#Include "Protheus.ch"
#Include "Topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT097LOK
O ponto se encontra no inicio da fun��o A097LIBERA antes da cria��o da dialog de libera��o e bloqueio, pode ser utilizado para validar se a opera��o deve continuar ou n�o conforme seu retorno, ou ainda pode ser usado para substituir o programa de libera��o por um especifico do usuario.

@type function
@author Thiago Rasmussen
@since 10/05/2017
@version P12.1.23

@obs Desenvolvimento FIEG - 02 - Compras

@history 26/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna verdadeiro se valida��es OK.
/*/
/*/================================================================================================================================/*/

User Function MT097LOK() 

Local lRet		  := .T.
Local _MV_XBLQALC := SuperGetMV("MV_XBLQALC", .F.)
Local _CONTRATO   := .T.

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
SC7->( DbSetOrder(1) )
SC7->( MsSeek(SCR->CR_FILIAL + ALLTRIM(SCR->CR_NUM)) )
                         
If !Empty(SC7->C7_CONTRA) .AND. !Empty(SC7->C7_MEDICAO)
	_CONTRATO := POSICIONE("CN9", 1, IIF(Empty(SC7->C7_XFILCOM), SC7->C7_FILIAL, SC7->C7_XFILCOM) + SC7->C7_CONTRA + SC7->C7_CONTREV, "CN9_XREGP") == "1"
EndIf
                           
If _CONTRATO .AND. RetCodUsr()$(_MV_XBLQALC) .AND. SCR->CR_TOTAL > 4000.00
	MsgAlert("O usu�rio " + UsrFullName(RetCodUsr()) + " deve realizar a aprova��o dos pedidos de compra com valor acima de R$ 4.000,00 pelo SE Su�te.","MT097LOK") 
	lRet := .F.
EndIf

Return lRet
