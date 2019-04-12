#Include "Protheus.ch"
#Include "TbiConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120COR
Ponto de entrada para incluir legenda nova no PC.

@type function
@author Alexandre Cadubtiski - TOTVS
@since Nov/2010
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Cores personalizadas das Legendas.
/*/
/*/================================================================================================================================/*/

User Function MT120COR()

	Local aNewCores := {}
	Local lCompraC := GetMv("SI_COMPRAC")
	Local nI := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aAdd(aNewCores,    { 'C7_TIPO!=nTipoPed'                       											, 'BR_PRETO'})	 //-- Autorizacao de Entrega ou Pedido
	aAdd(aNewCores,    { "C7_QUJE==0 .And. C7_RESIDUO=='S' .AND. !Empty(C7_XCANCE)"	, 'BR_CANCEL'}) //-- Pedido Cancelado
	aAdd(aNewCores,    { '!Empty(C7_RESIDUO)'                      											, 'BR_CINZA'})	 //-- Eliminado por Residuo
	aAdd(aNewCores,    { 'C7_CONAPRO=="B".And.C7_QUJE < C7_QUANT'											, 'BR_AZUL' })	 //-- Bloqueado

	If nTipoPed == 1
		aAdd(aNewCores,{ '!Empty(C7_CONTRA).And. Empty(C7_RESIDUO) .AND. Empty(C7_DTEMIPT)'/* .AND. Empty(C7_COMUNIC)'*/, 'BR_BRANCO'}) //-- Integracao com o Modulo de Gestao de Contratos
		Aadd(aNewCores,{ '!Empty(C7_CONTRA).And. Empty(C7_RESIDUO) .AND. Empty(C7_DTEMIPT)' /*.AND. !Empty(C7_COMUNIC)'*/, 'PMSTASK4'}) //-- Pedido do GCT Comunicado
	EndIf

	aAdd(aNewCores,    {/*'!empty(C7_COMUNIC) .And. */'C7_QUJE==0 .And. Empty(C7_XSTATUS) .And. C7_QTDACLA==0 .And. Empty(C7_DTEMIPT)', 'PMSTASK4'}) //-- Pedido Comunicado
	aAdd(aNewCores,    {/* 'empty(C7_COMUNIC) .And. */'C7_QUJE==0 .And. Empty(C7_XSTATUS) .And. C7_QTDACLA==0 .And. Empty(C7_DTEMIPT)', 'ENABLE'})	//-- Pendente
	//*
	aAdd(aNewCores,    { 'C7_QUJE<>0.And.C7_QUJE<C7_QUANT'													, 'BR_AMARELO'}) //-- Pedido Parcialmente Atendido
	aAdd(aNewCores,    { 'C7_QUJE>=C7_QUANT'   																, 'DISABLE'})	 //-- Pedido Atendido
	aAdd(aNewCores,    { 'C7_QTDACLA >0' 																	, 'BR_LARANJA'}) //-- Pedido Usado em Pre-Nota
	aAdd(aNewCores,    { "C7_QUJE==0 .And. C7_QTDACLA==0 .AND. C7_XSTATUS == '1'"							, 'BR_PINK'}) 	 //-- Recebido pelo fornecedor
	aAdd(aNewCores,    { "C7_QUJE==0 .And. C7_QTDACLA==0 .AND. C7_XSTATUS == '2'"							, 'BR_VIOLETA'}) //-- Confirmado pelo fornecedor

	If (lCompraC)
		For nI := 1 To Len(aNewCores)
			aNewCores[nI][1] += " .And. (SC7->C7_XMODOC == '0' .Or. Empty(SC7->C7_XMODOC))"
		Next nI

		aAdd(aNewCores, {'SC7->C7_XMODOC == "1"', "PMSTASK3"}) // SC Transferida (Participante)
		aAdd(aNewCores, {'SC7->C7_XMODOC == "2"', "PMSTASK2"}) // SC Incluida por Transferencia (Centralizadora)
	Endif
	//*/
	aAdd(aNewCores,    { "C7_QUJE==0 .And. C7_QTDACLA==0 .AND. Empty(C7_XSTATUS) .AND. !Empty(C7_DTEMIPT)"	, 'BR_MARRON'})  //-- WF enviad

Return(aNewCores)
