#Include "Protheus.ch"
#Include "TOPCONN.CH"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN130PGRV
Ponto de entrada executado ap�s a grava��o da Medi��o.

@type function
@author danielflavio
@since 04/12/2018
@version P12.1.23

@param Parametro_01, Num�rico, Informe a descri��o do 1� par�mtro.

@obs Desenvolvimento FIEG

@history 11/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Nil, Fun��o sem retorno.
/*/
/*/================================================================================================================================/*/

/*
	PARAMIXB
	-----------------------------------------------------------------------------------------------
	| Nome	|	  Tipo		| 							Descri��o								  |
	-----------------------------------------------------------------------------------------------
	| ExpN1 |  	Num�rico	|	Op��o da rotina de inclus�o, altera��o, exclus�o, visualiza��o.   |	
	|		|				|			2-Visualiizar; 3-Incluir;4-Alterar;5-Excluir			  |
	-----------------------------------------------------------------------------------------------
*/

User Function CN130PGRV()

	Local aXArea	:= GetArea()
	Local nXOpc 	:= ParamixB[1]
	Local nXAux		:= 0
	Local nXMedLanc	:= 0
	Local nXValorRP	:= 0
	Local lXGrava	:= .F.
	Local lXRPCont	:= SuperGetMv("SI_XRPCONT",.F.,.T.)	
	
	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< lXRPCont - Faz parte do processo de contabiliza��o de contratos como restos a pagar >--
	If lXRPCont
		If nXOpc = 3 										// Inclus�o
			//--< Verifica se a medi��o faz parte de algum contrato de restos a pagar >--
			If U_fXResto99("IS_RP",CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_REVISA)
			
				//--< Verifica se contrato � resto a pagar total >--
				If U_fXResto99("IS_TOTAL",CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_REVISA)
					RecLock("CND",.F.)
						CND->CND_XRESTP := "T"
					CND->(msUnlock())
				Else
					//--< Recebe o valor restos a pagar setado pela contabilidade atrav�s da rotina SICTBA99 >--
					nXValorRP := U_fXResto99("VALOR",CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_REVISA)
					
					//--< Recebe o valor j� lan�ado nas medi��es >--
					nXMedLanc := U_fXResto99("MEDICOES_RESTOS_PAGAR_LANCADAS",CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_REVISA)
					
					//--< Verifica se o valor ser� gravado ou n�o. Observando que para medi��es de contratos >--
					//--< com restos a pagar PARCIAL, o valor n�o pode ser ultrapassado nas medi��es >----------
					If nXMedLanc >= nXValorRP
						lXGrava := .F.
					Else
						lXGrava := .T.
						//--< Verifica se o valor da medi��o atual com o das medi��es j� lan�adas >-----
						//--< n�o ultrapassa o limite. Caso ultrapasse, ir� proporcionalizar o valor >--
						If CND->CND_VLTOT + nXMedLanc <= nXValorRP
							nXAux := CND->CND_VLTOT
						Else
							nXAux := nXValorRP - nXMedLanc
						EndIf
					EndIf
					
					If lXGrava
						RecLock("CND",.F.)
							CND->CND_XRESTP := "P"
							CND->CND_XRESTV	:= nXAux
						CND->(msUnlock())
					EndIf			
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aXArea)

Return
