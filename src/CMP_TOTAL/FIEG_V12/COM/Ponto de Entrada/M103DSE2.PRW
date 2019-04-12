#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} M103DSE2
Ponto de Entrada para para excluir mutuo dos titulos .

@type function
@author TOTVS
@since 11/11/2009
@version P12.1.23

@obs Projeto ELO

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function M103DSE2()

Local _cArea  := GetArea()
Local _cMutuo := SE2->E2_XMUTUO

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Tratamento do Mútuo >---------------------------------
IF !Empty(_cMutuo)
	
	SZX->(dbSetOrder(1))
	SZX->(dbSeek(XFilial("SZX")+_cMutuo))
	
	While SZX->(!Eof()) .and. SZX->ZX_FILIAL == XFilial("SZX") .and. SZX->ZX_RATEIO == _cMutuo
		//--< Exclui registros da tabela de mutuo >---------
		RecLock("SZX",.F.)
			SZX->(dbDelete())
		SZX->(MsUnlock())
		SZX->(dbSkip())
	EndDo
	
	SZY->(dbSetOrder(1))
	SZY->(dbSeek(XFilial("SZY")+_cMutuo))
	
	While !SZY->(Eof()) .and. SZY->ZY_FILIAL == xFilial("SZY") .and. SZY->ZY_RATEIO == _cMutuo
		//--< Exclui registros do rateio contabil >---------
		RecLock("SZY",.F.)
			SZY->(dbDelete())
		SZY->(MsUnlock())
		SZY->(dbSkip())
	EndDo

EndIf

RestArea(_cArea)

Return()
