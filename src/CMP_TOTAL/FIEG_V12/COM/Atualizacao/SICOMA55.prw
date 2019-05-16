#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SICOMA55  ºAutor  ³Felipe Alves        º Data ³  26/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE para gravação do mútuo nas SC's.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11 - SISTEMA INDUSTRIA                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SICOMA55()
Local aArea                  := {GetArea(), SC1->(GetArea()), SZT->(GetArea()), SZU->(GetArea()), SZV->(GetArea())}
Local lRet                   := .T.
Local cNumSC                 := SC1->(C1_NUM)
Local nItem                  := 1
Local lAchou                 := .F.
Local cCC                    := AllTrim(SC1->(C1_CC))
Local cItemCta               := AllTrim(SC1->(C1_ITEMCTA))

If ((INCLUI) .Or. (ALTERA))
	DbSelectArea("SZT")
	SZT->(DbSetOrder(2)) 
	DbSeek(xFilial("SZT") + cValToChar(Year(dDataBase)) + "2")
	If Found()
		DbSelectArea("SZU")
		SZU->(DbSetOrder(1))
		If (SZU->(DbSeek(xFilial("SZU") + SZT->(ZT_ANO) + SZT->(ZT_REVISAO))))
			While((SZU->(!Eof())) .And. (SZU->(ZU_ANO) == SZT->(ZT_ANO)) .And. (SZU->(ZU_REVISAO) == SZT->(ZT_REVISAO)))
				If ((cCC == AllTrim(SZU->(ZU_CC))) .And. (cItemCta == AllTrim(SZU->(ZU_ITCTB))))
					DbSelectArea("SZV")
					SZV->(DbSetOrder(1))
					If (SZV->(DbSeek(xFilial("SZV") + SZU->(ZU_ANO) + SZU->(ZU_REVISAO) + SZU->(ZU_ITEM))))
						nItem                 := 1
						
						While ((SZV->(!Eof())) .And. (SZU->(ZU_ANO) == SZV->(ZV_ANO)) .And. ;
								(SZU->(ZU_REVISAO) == SZV->(ZV_REVISAO)) .And. (SZU->(ZU_ITEM) == SZV->(ZV_ITEMSZU)))
							RecLock("SZW", .T.)
							SZW->(ZW_FILIAL) := xFilial("SZW")
							SZW->(ZW_ITEM)   := StrZero(nItem, TamSX3("ZW_ITEM")[1])
							SZW->(ZW_CODEMP) := SZV->(ZV_CODEMP)
							SZW->(ZW_PERC)   := SZV->(ZV_PERC)
							SZW->(ZW_NUMSC)  := SC1->(C1_NUM)
							SZW->(ZW_ITEMSC) := SC1->(C1_ITEM)
							SZW->(ZW_USER)   := __cUserId
							SZW->(MsUnlock())
		
							nItem++

							SZV->(DbSkip())
						Enddo
						
						lAchou := .T.
					Endif
				Endif

				SZU->(DbSkip())
			Enddo
		Endif
	Endif
	
	If !(lAchou)
		DbSelectArea("SC1")
		SC1->(DbSetOrder(1))
		SC1->(DbSeek(xFilial("SC1") + cNumSC))
		cItem:= SC1->C1_ITEM

		DbSelectArea("SZW")
		SZW->(DbSetOrder(1))
		If (!SZW->(DbSeek(xFilial("SZW") + SC1->(C1_NUM) + SC1->(C1_ITEM))))
		
		While ((SC1->(!Eof())) .And. (SC1->(C1_FILIAL) == xFilial("SC1")) .And. (SC1->(C1_NUM) == cNumSC)) .And. (SC1->(C1_ITEM) == cItem)
			RecLock("SZW", .T.)
			SZW->(ZW_FILIAL)     := xFilial("SZW")
			SZW->(ZW_ITEM)       := StrZero(nItem, TamSX3("ZW_ITEM")[1])
			SZW->(ZW_CODEMP)     := xFilial("SZW")
			SZW->(ZW_PERC)       := 100
			SZW->(ZW_NUMSC)      := SC1->(C1_NUM)
			SZW->(ZW_ITEMSC)     := SC1->(C1_ITEM)
			SZW->(ZW_USER)       := __cUserId
			SZW->(MsUnlock())
			
			nItem++
		
			SC1->(DbSkip())

		Enddo
		EndIf
	Endif
Endif

aEval(aArea, {|x| RestArea(x)})
Return(lRet)