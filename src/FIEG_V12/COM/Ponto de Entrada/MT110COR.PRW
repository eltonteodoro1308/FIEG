#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110COR
Ponto de Entrada para manipulacao das cores do browse da SC.

@type function
@author Thiago Rasmussen
@since 23/04/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Retorna Array com lista de cores das legendas customizadas conforme necessário.

/*/
/*/================================================================================================================================/*/

User Function MT110COR()

	Local _aRet := ParamIXB[1]

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aAdd(_aRet,{'SC1->C1_APROV == "O"',"FOLDER7"})	//SC Bloqueada por Orçamento
	aAdd(_aRet,{'SC1->C1_APROV == "C"',"FOLDER5"})  //SC Aguardando Contingencia
	aAdd(_aRet,{'SC1->C1_APROV == "F"',"FOLDER14"}) //SC Reprovada por Orçamento

	_aRet[03][1] := 'C1_COMPRAC == "1"'                                          //Solicitacao em Compra Centralizada
	_aRet[03][2] := 'METAS_CIMA_16'                                              //Solicitacao em Compra Centralizada
	_aRet[07][1] := 'C1_FLAGGCT == "1"'                                          //Integração Modulo Gestão de Contratos
	_aRet[07][2] := 'BR_VIOLETA'                                                 //Integração Modulo Gestão de Contratos
	_aRet[09][2] := 'BR_PINK'                                                    //Eliminação por Resíduo
	_aRet[10][1] := _aRet[10][1] + ' .AND. C1_QUANT > 0 .AND. C1_FLAGGCT != "1"' //Solicitacao Totalmente Atendida
	_aRet[15][1] := _aRet[15][1] + ' .AND. C1_FLAGGCT != "1"'                    //Solicitacao Parcialmente Atendida

Return _aRet
