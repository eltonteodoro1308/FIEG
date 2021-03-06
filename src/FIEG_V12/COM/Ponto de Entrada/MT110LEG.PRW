#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110LEG
Ponto de Entrada para manipulacao das cores da legenda.

@type function
@author Thiago Rasmussen
@since 20/04/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Array, Array de retorno contendo as novas legendas para a apresenta��o das cores do status da SC na mbrowse j� manipuladas.

/*/
/*/================================================================================================================================/*/

User Function MT110LEG()

	Local _aRet := ParamIXB[1]

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	Aadd(_aRet,{"FOLDER7"  ,"Bloqueado por Or�amento" })
	Aadd(_aRet,{"FOLDER5"  ,"Aguardando Contig�ncia" })
	Aadd(_aRet,{"FOLDER14" ,"Or�amento Reprovado" })

	_aRet[05][1] := 'BR_PINK'                //Elimina��o por Res�duo
	_aRet[05][2] := 'Elimina��o por Res�duo' //Elimina��o por Res�duo
	_aRet[08][2] := 'Al�ada Reprovada'       //Al�ada Reprovada
	_aRet[09][1] := 'BR_VIOLETA'             //Integra��o Modulo Gest�o de Contratos
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
