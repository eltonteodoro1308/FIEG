#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F050TMP1
Ponto de Entrada tratamento do rateio em rotina automatica.
PARÂMETROS
[1] = Tipo Digitado/Pré-configurado (numérico)
[2] = Cód. Rateio (caracter)
[3] = Programa/Rotina (caracter)
[4] = Lançamento padrão (caracter)
[5] = Conta débito (caracter)
[6] = Conta crédito (caracter)
[7] = Histórico (caracter)
[8] = Rotina automática (lógico)
[9] = Origem igual 1 - F050ESCRAT, 2 - CTBRATFIN (numérico)

@type function
@author Thiago Rasmussen
@since 11/04/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Retorno em forma de array no seguinte esquema: aRet[1] = Valor de rateio customizado / aRet[2] = Flag para abrir a tela de opções de rateio (maior que zero exibe tela de rateio)..

/*/
/*/================================================================================================================================/*/

User function F050TMP1()
	Local _cRotina := ParamIxb[3]
	Local _lAuto   := ParamIxb[8] // acesso via execauto
	Local _nOrig   := ParamIxb[9]
	Local _VrRat   := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Upper(Alltrim(_cRotina)) == "FINA100"
		_VrRat   := M->E5_VALOR
	Else
		_VrRat   := M->E2_VALOR
	Endif

	If _nOrig == 2 //Chamada pela CTBRATFIN
		IF _lAuto
			IF IsInCallStack("U_SIFINA11") // Origem Rateio Mutuo
				SZY->(dbSetOrder(1))
				IF SZY->(dbSeek(XFilial("SZY")+SZX->(ZX_RATEIO+ZX_ITEM)))
					_aStruTMP := TMP->(dbStruct())
				ENDIF

				While SZY->(!Eof()) .and. SZY->ZY_FILIAL == XFilial("SZY") .and. SZY->(ZY_RATEIO+ZY_ITEMRAT) == SZX->(ZX_RATEIO+ZX_ITEM)
					Reclock("TMP",.T.)
					For i := 1 to Len(_aStruTMP)
						IF SZY->(FieldPos(Alltrim( StrTran(_aStruTMP[i,1],"CTJ_","ZY_") ))) > 0
							&(_aStruTMP[i,1]) := SZY->( &(StrTran(_aStruTMP[i,1],"CTJ_","ZY_")) )
						ENDIF
					Next
					CTJ_FLAG   := .F.
					CTJ_QTDDIS := CTJ_PERCEN
					TMP->(msUnlock())
					SZY->(dbSkip())
				Enddo
			ELSEIF IsInCallStack("U_SIESBA04") // Origem Rateio Mutuo


			ENDIF
		ELSE
			_VrRat := F050Carr(ParamIxb[1],ParamIxb[2],ParamIxb[3],ParamIxb[4],ParamIxb[5],ParamIxb[6],ParamIxb[7])
		ENDIF
	EndIf

Return({_VrRat,IIF(_lAuto,0,1)}) //{Valor do Rateio,Flag com a tela de opções do rateio}
