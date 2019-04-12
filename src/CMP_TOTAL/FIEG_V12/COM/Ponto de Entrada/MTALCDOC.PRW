#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTALCDOC
Permite manipular a tabela de documento de alçadas SCR, após ter sido gerada ou atualizada.

@type function
@author Thiago Rasmussen
@since 03/10/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User function MTALCDOC()

Local Param_1 := ParamIXB[1]
// [1] Número do Documento
// [2] Tipo de Documento
// [3] Valor do Documento 
// [4] Código do Aprovador 
// [5] Código do Usuário  
// [6] Grupo do Aprovador
// [7] Aprovador Superior  
// [8] Moeda do Documento
// [9] Taxa da Moeda 
// [10] Data de Emissão do Documento
//Local Param_2 := ParamIXB[2]

Local Param_3 := ParamIXB[3]

// 1 = Inclusão de Documento
// 2 = Transferência da Alçada para o Superior
// 3 = Exclusão do Documento
// 4 = Aprovação do Documento
// 5 = Estorno da Aprovação
// 6 = Bloqueio Manual

//Local aAreaSC1

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF Param_3 == 1 .OR. Param_3 == 5
	TCSPEXEC('SP_ALCADA_APROVACAO', xFILIAL('SCR'), Param_1[1], Param_1[2])
ENDIF	                       
  
/******************************************************************************************************
IF Param_1[2] == 'PC'
	aAreaSC7 := SC7->(GetArea())
	
	MsgRun('Enviando pedido para aprovação...',, {|| U_CWKFA003({'01',XFilial('SC7'),Param_1[1]})})
	
	RestArea(aAreaSC7)	
ENDIF
******************************************************************************************************/

Return NIL
