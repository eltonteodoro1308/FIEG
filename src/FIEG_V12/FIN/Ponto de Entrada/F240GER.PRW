#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F240GER
Valida se o bordero podera ser enviado para o arquivo de pagamento.

@type function
@author Thiago Rasmussen
@since 11/01/2012
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/

User Function F240GER()
	Local _lRet     := .t.
	Local cModelo   := GetNewPar("SI_MODALID","")
	Local _cAreaSEA := SEA->(GetArea())


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SEA->(dbSetOrder(1))
	SEA->(dbSeek(xFilial("SEA")+mv_par01,.T.))
	While SEA->(!Eof()) .and. SEA->EA_NUMBOR <= mv_par02 .and. SEA->EA_FILIAL == xFilial()
		If SEA->EA_CART == "P" .and. SEA->EA_MODELO $ cModelo
			Aviso("ATENÇÃO","Existem borderôs com modalidade "+cModelo+" e não podem ser enviados ao banco. Verifique!",{"Sair"})
			_lRet := .f.
			Exit
		Endif
		SEA->(dbSkip())
	Enddo

	RestArea(_cAreaSEA)
Return _lRet
