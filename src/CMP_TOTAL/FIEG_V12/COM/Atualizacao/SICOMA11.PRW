#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA11
Gravacao dos lançamentos orçamentários.

@type function
@author Thiago Rasmussen
@since 13/10/2011
@version P12.1.23

@param ParamIXB, Array, Array com lista de parâmetros da função.

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA11(ParamIXB)

	Local _aArea     := GetArea()
	Local _aAreaSC1  := SC1->(GetArea())
	Local _aAreaSC7  := SC7->(GetArea())
	Local _aAreaSCH  := SCH->(GetArea())
	Local _cLanctoPC := Alltrim(GetNewPar("SI_PCOPC","900052"))
	Local _cLanctoRT := Alltrim(GetNewPar("SI_PCORT","900376"))

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Lançamento dos movimentos orçamentarios - GAP091
	IF SC7->C7_TIPO == 1 .and. ParamIXB[3] == 1 .and. PcoExistLc(_cLanctoPC,"01","1")

		l120Visual := .F.
		l120Inclui := .F.
		l120Altera := .F.
		l120Deleta := .F.
		l120Visual := .F.

		Do Case
			Case ParamIXB[1] == 2
			l120Visual := .T.
			Case ParamIXB[1] == 3 .Or. IsInCallStack("A120Copia")
			l120Inclui	:= .T.
			Case ParamIXB[1] == 4
			l120Altera	:= .T.
			Case ParamIXB[1] == 5
			l120Deleta	:= .T.
			l120Visual	:= .T.
		EndCase

		_cNumPC := SC7->C7_NUM

		SC7->(dbSetOrder(1))
		SC7->(dbSeek(XFilial("SC7")+_cNumPC))

		While SC7->(!Eof()) .and. SC7->(C7_FILIAL+C7_NUM) == XFilial("SC7")+_cNumPC

			SC1->(dbSetOrder(1))
			IF SC1->(dbSeek(XFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC)))
				PcoIniLan(_cLanctoPC)

				SZW->(dbSetOrder(1))
				IF SZW->(MsSeek(xFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))

					_cFilBkp := cFilAnt
					While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)
						// Altera empresa
						cFilAnt := SZW->ZW_CODEMP

						_NPERCEMP := SZW->ZW_PERC

						SCH->(dbSetOrder(2))
						// Rateio por Item PC
						IF SCH->(dbSeek(XFilial("SCH")+SC7->(C7_NUM+C7_ITEM)))
							While SCH->(!Eof()) .and. SCH->CH_FILIAL == XFilial("SCH") .and. SCH->(CH_PEDIDO+CH_ITEMPD) == SC7->(C7_NUM+C7_ITEM)
								PcoIniLan(_cLanctoRT)
								PcoDetLan(_cLanctoRT,'01','MATA120',l120Deleta)
								PcoFinLan(_cLanctoRT)
								SCH->(dbSkip())
							Enddo
							// Estorno da SC quando tem rateio
							PcoIniLan(_cLanctoPC)
							PcoDetLan(_cLanctoPC,'02','MATA120',l120Deleta)
							PcoFinLan(_cLanctoPC)
						ELSE
							// Lançamento realizado
							PcoIniLan(_cLanctoPC)
							PcoDetLan(_cLanctoPC,'01','MATA120',l120Deleta)
							PcoFinLan(_cLanctoPC)
						ENDIF

						// Restaura filial
						cFilAnt := _cFilBkp

						SZW->(dbSkip())
					Enddo
				ELSE
					SCH->(dbSetOrder(2))
					// Rateio por Item PC
					IF SCH->(dbSeek(XFilial("SCH")+SC7->(C7_NUM+C7_ITEM)))
						While SCH->(!Eof()) .and. SCH->CH_FILIAL == XFilial("SCH") .and. SCH->(CH_PEDIDO+CH_ITEMPD) == SC7->(C7_NUM+C7_ITEM)
							PcoIniLan(_cLanctoRT)
							PcoDetLan(_cLanctoRT,'01','MATA120',l120Deleta)
							PcoFinLan(_cLanctoRT)
							SCH->(dbSkip())
						Enddo
						// Estorno da SC quando tem rateio
						PcoIniLan(_cLanctoPC)
						PcoDetLan(_cLanctoPC,'02','MATA120',l120Deleta)
						PcoFinLan(_cLanctoPC)
					ELSE
						PcoIniLan(_cLanctoPC)
						PcoDetLan(_cLanctoPC,'01','MATA120',l120Deleta)
						PcoFinLan(_cLanctoPC)
					ENDIF
				ENDIF

				_NPERCEMP := 0

				PcoFinLan(_cLanctoPC)
			ELSE

				SC1->(dbSetOrder(8))
				IF !Empty(SC7->(C7_CODED+C7_NUMPR)) .and. SC1->(dbSeek(XFilial("SC1")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))

					PcoIniLan(_cLanctoPC)

					While SC1->(!Eof()) .and. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == SC7->(C7_FILIAL+C7_CODED+C7_NUMPR+C7_PRODUTO)

						SZW->(dbSetOrder(1))
						IF SZW->(MsSeek(xFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))

							_cFilBkp := cFilAnt
							While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)
								// Altera empresa
								cFilAnt := SZW->ZW_CODEMP

								_NPERCEMP := SZW->ZW_PERC

								SCH->(dbSetOrder(2))
								// Rateio por Item PC
								IF SCH->(dbSeek(XFilial("SCH")+SC7->(C7_NUM+C7_ITEM)))
									While SCH->(!Eof()) .and. SCH->CH_FILIAL == XFilial("SCH") .and. SCH->(CH_PEDIDO+CH_ITEMPD) == SC7->(C7_NUM+C7_ITEM)
										PcoIniLan(_cLanctoRT)
										PcoDetLan(_cLanctoRT,'01','MATA120',l120Deleta)
										PcoFinLan(_cLanctoRT)
										SCH->(dbSkip())
									Enddo
									// Estorno da SC quando tem rateio
									PcoIniLan(_cLanctoPC)
									PcoDetLan(_cLanctoPC,'02','MATA120',l120Deleta)
									PcoFinLan(_cLanctoPC)
								ELSE
									// Lançamento realizado
									PcoIniLan(_cLanctoPC)
									PcoDetLan(_cLanctoPC,'01','MATA120',l120Deleta)
									PcoFinLan(_cLanctoPC)
								ENDIF

								// Restaura filial
								cFilAnt := _cFilBkp

								SZW->(dbSkip())
							Enddo
						ELSE
							SCH->(dbSetOrder(2))
							// Rateio por Item PC
							IF SCH->(dbSeek(XFilial("SCH")+SC7->(C7_NUM+C7_ITEM)))
								While SCH->(!Eof()) .and. SCH->CH_FILIAL == XFilial("SCH") .and. SCH->(CH_PEDIDO+CH_ITEMPD) == SC7->(C7_NUM+C7_ITEM)
									PcoIniLan(_cLanctoRT)
									PcoDetLan(_cLanctoRT,'01','MATA120',l120Deleta)
									PcoFinLan(_cLanctoRT)
									SCH->(dbSkip())
								Enddo
								// Estorno da SC quando tem rateio
								PcoIniLan(_cLanctoPC)
								PcoDetLan(_cLanctoPC,'02','MATA120',l120Deleta)
								PcoFinLan(_cLanctoPC)
							ELSE
								PcoIniLan(_cLanctoPC)
								PcoDetLan(_cLanctoPC,'01','MATA120',l120Deleta)
								PcoFinLan(_cLanctoPC)
							ENDIF

						ENDIF

						_NPERCEMP := 0

						SC1->(dbSkip())
					Enddo

					PcoFinLan(_cLanctoPC)

				ELSE
					SCH->(dbSetOrder(2))
					// Rateio por Item PC
					IF SCH->(dbSeek(XFilial("SCH")+SC7->(C7_NUM+C7_ITEM)))
						While SCH->(!Eof()) .and. SCH->CH_FILIAL == XFilial("SCH") .and. SCH->(CH_PEDIDO+CH_ITEMPD) == SC7->(C7_NUM+C7_ITEM)
							PcoIniLan(_cLanctoRT)
							PcoDetLan(_cLanctoRT,'01','MATA120',l120Deleta)
							PcoFinLan(_cLanctoRT)
							SCH->(dbSkip())
						Enddo
					ELSE
						PcoIniLan(_cLanctoPC)
						PcoDetLan(_cLanctoPC,'01','MATA120',l120Deleta)
						PcoFinLan(_cLanctoPC)
					ENDIF

				ENDIF
			ENDIF

			SC7->(dbSkip())
		Enddo

	ENDIF

	RestArea(_aArea)
	RestArea(_aAreaSC1)
	RestArea(_aAreaSC7)
	RestArea(_aAreaSCH)
Return
