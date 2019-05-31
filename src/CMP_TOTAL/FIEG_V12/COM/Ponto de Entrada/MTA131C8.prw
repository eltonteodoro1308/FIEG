#INCLUDE "TOTVS.CH"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MTA131C8
Ponto de entrada ao gerar cotação
@author     Totvs..
@since     	29/05/2019
@version  	P.11.1.23      
@param 		Nenhum
@return    	Nenhum
@obs        Nenhum
Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+----------------------------------------------------------
Data       	|Desenvolvedor    |Motivo                                                                                                                 
------------+----------------+----------------------------------------------------------
		  	|				  | 
------------+-----------------+----------------------------------------------------------
/*/
//---------------------------------------------------------------------------------------
USER FUNCTION MTA131C8() 

Local oModFor := ParamIxb[1] 

If SC8->(FieldPos("C8_XESPEC")) > 0
	oModFor:LoadValue("C8_XESPEC",SC1->C1_XESPEC)
EndIf

Return()