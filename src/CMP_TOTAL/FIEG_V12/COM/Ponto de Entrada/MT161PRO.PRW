
#INCLUDE "PROTHEUS.CH"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA160TOK
Ponto de Entrada chamado ao clicar o Analise Cotacao. 
Este P.E guardara o fornecedor e loja escolhido como ganhador pelo sistema.

@type function
@author Eduardo Dias
@since 29/05/2019
@version P12.1.23

@obs Este P.E e utilizado junto com o MT161OK.PRW

@history 29/05/2019, eduardo.dias@TOTVS.com.br, Substituiu o P.E MA160TOK.PRW - Protheus 12.1.23.

@return Retorna Array com o Cod.Fornecedor e Loja que foi selecionado automaticamente pelo sistema.

/*/
/*/================================================================================================================================/*/
	
User Function MT161PRO()

Local aPropostas	:= PARAMIXB[1]
Local aArea			:= GetArea()
Local nCont			:= 1
Local nFiOri		:= SC8->C8_FILIAL
Local nCotacao		:= SC8->C8_NUM

PUBLIC aGanha161	:= {1,1}

cQuery := "UPDATE "
cQuery += " "+RetSqlName("SC8")+""
cQuery += " SET C8_OBS = CAST('' AS VARBINARY(MAX)) "
cQuery += " WHERE C8_FILIAL = '"+nFiOri+"' "
cQuery += " AND C8_NUM = '"+nCotacao+"' "
cQuery += " AND D_E_L_E_T_ = ' ' "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Falha no update da SC8 - Verifique o P.E MT161PRO" + TCSQLError())
EndIf

For nA := 1 To Len(aPropostas[1])

	nQtdProp := Len(aPropostas[1][nA])
	
	For nB := 1 To Len(aPropostas[1][nA])
	
		If valtype(aPropostas[1][nA]) == "A"

			For nC	:= 1 To Len(aPropostas[1][nA][nB])
				
				If valtype(aPropostas[1][nA][nB][nC]) == "A"
			
					For nD := 1 To Len(aPropostas[1][nA][nB][nC]) //Verificar quantos Itens tem na Cotação
					
						If valtype(aPropostas[1][nA][nB][nC]) == "A"
						
							If nD == 1 .And. aPropostas[1][nA][nB][nC][1] == .T.
								
								If Len( aGanha161 ) <= nCont

									aGanha161[nCont] := {aPropostas[1][nA][1][1],;
													aPropostas[1][nA][1][2]}

								End If
												
								nCont++

							EndIf
																	
						EndIf		
						
					Next nD
				
				EndIf
			
			Next nC
			
		EndIf
			
	Next nB

Next nA

If Select("TRBSC8") > 0 
	DBSelectArea("TRBSC8")
	DBCloseArea()
EndIf

RestArea(aArea)

Return aPropostas