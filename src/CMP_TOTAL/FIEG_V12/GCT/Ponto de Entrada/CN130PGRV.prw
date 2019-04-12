#Include "Protheus.ch"
#Include "TOPCONN.CH"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN130PGRV
Ponto de entrada executado após a gravação da Medição.

@type function
@author danielflavio
@since 04/12/2018
@version P12.1.23

@param Parametro_01, Numérico, Informe a descrição do 1º parêmtro.

@obs Desenvolvimento FIEG

@history 11/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

/*
	PARAMIXB
	-----------------------------------------------------------------------------------------------
	| Nome	|	  Tipo		| 							Descrição								  |
	-----------------------------------------------------------------------------------------------
	| ExpN1 |  	Numérico	|	Opção da rotina de inclusão, alteração, exclusão, visualização.   |	
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
	
	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< lXRPCont - Faz parte do processo de contabilização de contratos como restos a pagar >--
	If lXRPCont
		If nXOpc = 3 										// Inclusão
			//--< Verifica se a medição faz parte de algum contrato de restos a pagar >--
			If U_fXResto99("IS_RP",CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_REVISA)
			
				//--< Verifica se contrato é resto a pagar total >--
				If U_fXResto99("IS_TOTAL",CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_REVISA)
					RecLock("CND",.F.)
						CND->CND_XRESTP := "T"
					CND->(msUnlock())
				Else
					//--< Recebe o valor restos a pagar setado pela contabilidade através da rotina SICTBA99 >--
					nXValorRP := U_fXResto99("VALOR",CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_REVISA)
					
					//--< Recebe o valor já lançado nas medições >--
					nXMedLanc := U_fXResto99("MEDICOES_RESTOS_PAGAR_LANCADAS",CND->CND_FILIAL,CND->CND_CONTRA,CND->CND_REVISA)
					
					//--< Verifica se o valor será gravado ou não. Observando que para medições de contratos >--
					//--< com restos a pagar PARCIAL, o valor não pode ser ultrapassado nas medições >----------
					If nXMedLanc >= nXValorRP
						lXGrava := .F.
					Else
						lXGrava := .T.
						//--< Verifica se o valor da medição atual com o das medições já lançadas >-----
						//--< não ultrapassa o limite. Caso ultrapasse, irá proporcionalizar o valor >--
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
