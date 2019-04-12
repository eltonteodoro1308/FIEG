#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110LEG
Ponto de Entrada para manipulacao das cores da legenda.

@type function
@author Thiago Rasmussen
@since 20/04/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array de retorno contendo as novas legendas para a apresentação das cores do status da SC na mbrowse já manipuladas.

/*/
/*/================================================================================================================================/*/

User Function MT110LEG()

	Local _aRet := ParamIXB[1]

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	Aadd(_aRet,{"FOLDER7"  ,"Bloqueado por Orçamento" })
	Aadd(_aRet,{"FOLDER5"  ,"Aguardando Contigência" })
	Aadd(_aRet,{"FOLDER14" ,"Orçamento Reprovado" })

	_aRet[05][1] := 'BR_PINK'                //Eliminação por Resíduo
	_aRet[05][2] := 'Eliminação por Resíduo' //Eliminação por Resíduo
	_aRet[08][2] := 'Alçada Reprovada'       //Alçada Reprovada
	_aRet[09][1] := 'BR_VIOLETA'             //Integração Modulo Gestão de Contratos
	_aRet[11][1] := 'METAS_CIMA_16'          //Solicitacao em Compra Centralizada

	ADel(_aRet, 17)
	ADel(_aRet, 16)
	ADel(_aRet, 15)
	ADel(_aRet, 14)
	ADel(_aRet, 13)
	ADel(_aRet, 12)
	ADel(_aRet, 07)
	ASize(_aRet, LEN(_aRet) - 7)

Return _aRet
