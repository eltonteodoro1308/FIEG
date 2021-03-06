#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTALCDOC
Permite manipular a tabela de documento de al�adas SCR, ap�s ter sido gerada ou atualizada.

@type function
@author Thiago Rasmussen
@since 03/10/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Nil, Fun��o sem retorno.
/*/
/*/================================================================================================================================/*/

User function MTALCDOC()

Local Param_1 := ParamIXB[1]
// [1] N�mero do Documento
// [2] Tipo de Documento
// [3] Valor do Documento 
// [4] C�digo do Aprovador 
// [5] C�digo do Usu�rio  
// [6] Grupo do Aprovador
// [7] Aprovador Superior  
// [8] Moeda do Documento
// [9] Taxa da Moeda 
// [10] Data de Emiss�o do Documento
//Local Param_2 := ParamIXB[2]

Local Param_3 := ParamIXB[3]

// 1 = Inclus�o de Documento
// 2 = Transfer�ncia da Al�ada para o Superior
// 3 = Exclus�o do Documento
// 4 = Aprova��o do Documento
// 5 = Estorno da Aprova��o
// 6 = Bloqueio Manual

//Local aAreaSC1

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF Param_3 == 1 .OR. Param_3 == 5
	TCSPEXEC('SP_ALCADA_APROVACAO', xFILIAL('SCR'), Param_1[1], Param_1[2])
ENDIF	                       
  
/******************************************************************************************************
IF Param_1[2] == 'PC'
	aAreaSC7 := SC7->(GetArea())
	
	MsgRun('Enviando pedido para aprova��o...',, {|| U_CWKFA003({'01',XFilial('SC7'),Param_1[1]})})
	
	RestArea(aAreaSC7)	
ENDIF
******************************************************************************************************/

Return NIL
