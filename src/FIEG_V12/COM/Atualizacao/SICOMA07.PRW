#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA07
Gravacao dos lançamentos orçamentários da NFE.

@type function
@author Thiago Rasmussen
@since 13/10/2011
@version P12.1.23

@param ParamIXB, Array, Array com parâmetros da Função.

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA07(ParamIXB)
	Local _aArea     := GetArea()
	Local _aAreaSC1  := SC1->(GetArea())
	Local _aAreaSD1  := SC7->(GetArea())
	Local _cLanctoPC := Alltrim(GetNewPar("SI_PCONF","900054"))

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Lançamento dos movimentos orçamentarios - GAP091
	IF ParamIXB[2] == 1 .and. PcoExistLc(_cLanctoPC,"01","1")

		l103Visual := .F.
		l103Inclui := .F.
		l103Altera := .F.
		l103Deleta := .F.
		l103Visual := .F.

		Do Case
			Case ParamIXB[1] == 2
			l103Visual := .T.
			Case ParamIXB[1] == 3
			l103Inclui	:= .T.
			Case ParamIXB[1] == 4
			l103Altera	:= .T.
			Case ParamIXB[1] == 5
			l103Deleta	:= .T.
			l103Visual	:= .T.
		EndCase

		SD1->(dbSetOrder(1))
		SD1->(dbSeek(XFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

		While SD1->(!Eof()) .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

			SC7->(dbSetOrder(1))
			IF SC7->(dbSeek(XFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC)))

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

							// Lançamento realizado
							PcoIniLan(_cLanctoPC)
							PcoDetLan(_cLanctoPC,'01','MATA103',l103Deleta)
							PcoFinLan(_cLanctoPC)

							// Restaura filial
							cFilAnt := _cFilBkp

							SZW->(dbSkip())
						Enddo
					ELSE
						PcoIniLan(_cLanctoPC)
						PcoDetLan(_cLanctoPC,'01','MATA103',l103Deleta)
						PcoFinLan(_cLanctoPC)
					ENDIF

					_NPERCEMP := 0

					PcoFinLan(_cLanctoPC)
				ELSE
					PcoIniLan(_cLanctoPC)
					PcoDetLan(_cLanctoPC,'01','MATA103',l103Deleta)
					PcoFinLan(_cLanctoPC)
				ENDIF

			ELSE
				PcoIniLan(_cLanctoPC)
				PcoDetLan(_cLanctoPC,'01','MATA103',l103Deleta)
				PcoFinLan(_cLanctoPC)
			ENDIF

			SD1->(dbSkip())
		Enddo

	ENDIF

	RestArea(_aArea)
	RestArea(_aAreaSC1)
	RestArea(_aAreaSD1)
Return
