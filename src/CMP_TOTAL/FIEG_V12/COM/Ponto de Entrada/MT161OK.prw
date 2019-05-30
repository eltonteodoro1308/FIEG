#Include 'Protheus.ch'
#Include "TOPCONN.CH"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA160TOK
Ponto de Entrada no final da analise cotacao.
Substituiu o P.E MA160TOK.PTE

@type function
@author Eduardo Dias
@since 29/05/2019
@version P12.1.23

@history 29/05/2019, eduardo.dias@TOTVS.com.br, Substituiu o P.E MA160TOK.PRW - Protheus 12.1.23.

@return Lógico, Retorna Verdadeiro ou Falso para .

/*/
/*/================================================================================================================================/*/

User Function MT161OK()
Local aPropostas	:= PARAMIXB[1] // Array contendo todos os dados da proposta da cotação
Local cTpDoc		:= PARAMIXB[2] // Tipo do documento
Local aArea			:= GetArea()
Local cQuery		:= "" 
Local cLocal		:= SC8->C8_FILIAL
Local cNumSC		:= SC8->C8_NUMSC
Local NVlrSC8		:= SC8->C8_PRECO
Local lRet			:= .T.
Local lCont			:= .T.
Local nSeq			:= 1

//DEFAULT aGanha161	:= {}

cQuery := "SELECT * "
cQuery += " FROM "+RetSqlName("SC1")+" SC1 "
cQuery += " WHERE SC1.C1_FILIAL = '"+cLocal+"' "
cQuery += " AND SC1.C1_NUM = '"+cNumSC+"' "
cQuery += " AND SC1.D_E_L_E_T_ = ' ' "
TCQUERY cQuery NEW ALIAS 'TRBSC1'

While !TRBSC1->(Eof())
	
	For nA := 1 To Len(aPropostas[1])
		nQtdProp := Len(aPropostas[1][nA])
		
		For nB := 1 To Len(aPropostas[1][nA])
			If valtype(aPropostas[1][nA]) == "A"
	
				For nC	:= 1 To Len(aPropostas[1][nA][nB])
					If valtype(aPropostas[1][nA][nB][nC]) == "A"
				
						For nD := 1 To Len(aPropostas[1][nA][nB][nC]) //Verificar quantos Itens tem na Cotação
						
							If valtype(aPropostas[1][nA][nB][nC]) == "A"
															
								If nD == 1 .And. aPropostas[1][nA][nB][nC][1] == .T.
									
									nItemSC8 := aPropostas[1][nA][nB][nC][10]
									nVlrSC8	 := aPropostas[1][nA][nB][nC][13]

									///////////////////////////////////////////////////////////////////////////////////////////////
									// Verifica se o valor da Cotação e menor do que o valor estimado na Solicitacao de Compras  //
									///////////////////////////////////////////////////////////////////////////////////////////////										
									If NVlrSC8 > TRBSC1->C1_VUNIT
										Help(NIL, NIL, "Valor Maior", NIL, "O valor unitário da cotação ganhadora não pode ultrapassar o valor unitário estimado na solicitação de compra.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Reavalie o valor da cotação do Produto "+ aPropostas[1][nA][nB][nC][3] + " o qual tem o valor da SC estimado à " + TRANSFORM(TRBSC1->C1_VUNIT, "@E 99999,99" ) }) //ALLTRIM(STR(TRBSC1->C1_VUNIT )) })
										//MSGALERT("O valor unitário da cotação ganhadora não pode ultrapassar o valor unitário estimado na solicitação de compra.", "Valor Maior")
										lRet := .F.
										lCont := .F.
									EndIf
									
									TRBSC1->(dbSkip())
									
									/////////////////////////////////////////////////////////////////////////////////////////////////////////////
									// Verifica se o Fornecedor selecionado e o mesmo fornecedor marcado como o ganhador sugerido pelo sistema //
									/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
									If lCont .And. nSeq <= nA .And. !(aPropostas[1][nA][1][1]+aPropostas[1][nA][1][2] == aGanha161[nSeq][1]+aGanha161[nSeq][2])
										If Empty(aPropostas[1][nA][nB][nC][6]) //Verifica se o Campo C8_OBS esta preenchido com a justificativa da troca de fornecedor
											Help(NIL, NIL, "Alteração do Ganhador", NIL, "Como o fornecedor ganhador foi alterado, deverá justificar o motivo. ", 1, 0, NIL, NIL, NIL, NIL, NIL, {" No campo 'OBS da cotação', informe o critério do julgamento e o motivo de ter selecionado outro ganhador para dar andamento"+ aPropostas[1][nA][nB][nC][3] })
											//MSGALERT("Devera justificar o motivo da troca do fornecedor no campo OBS", "Fornecedor alterado")
											nSeq++
											lRet := .F.
											lCont := .F.
										EndIf
									EndIf

									//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									// Verifica se a Cotacao contem 3 Fornecedores, se nao houver, verifica se o campo justificativa foi preenchido //
									//////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
									If nQtdProp < 3 .And. lCont
										If Empty(aPropostas[1][nA][nB][nC][6])
											
											Help(NIL, NIL, "Cotação com menos de 3 Propostas", NIL, "Para todos itens da cotação com menos de 3 propostas com valor, deverá ser justificado. ", 1, 0, NIL, NIL, NIL, NIL, NIL, {" No campo 'OBS da cotação', informe o critério do julgamento e o motivo de não conter no minimo 3 cotações. "})
											//MSGALERT("Para todos itens da cotação com menos de 3 propostas com valor, deverá ser justificado " + ;
											//	"é obrigatório informar um novo critério de julgamento e descrever o motivo, para cada um dos itens listados abaixo:")
											
											lRet := .F.
										EndIf
									EndIf
								
									lCont := .T.
									
								EndIf		
								
							EndIf
							
						Next nD
					
					EndIf
				
				Next nC
				
			EndIf
				
		Next nB
	
	Next nA
	
EndDo

If Select("TRBSC1") > 0 
	DBSelectArea("TRBSC1")
	DBCloseArea()
EndIf

RestArea(aArea)

Return (lRet)
