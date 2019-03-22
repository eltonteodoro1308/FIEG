#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA14
Alterar o status da Planilha e itens para Aberto (Zero).

@type function
@author Claudinei Ferreira
@since 24/02/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIPCOA14
	Local _aAreaAK2 := AK2->(GetArea())

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+------------------------------------+
	//|Atualiza campo AK1_XAPROV=0 (Aberto)  |
	//+------------------------------------+
	RecLock("AK1", .F.)
	AK1->AK1_XAPROV := '0'
	AK1->(MsUnLock())

	//+------------------------------------+
	//|Atualiza campo AK2_XSTS=0 (Aberto)  |
	//+------------------------------------+
	AK2->(dbSetOrder(1))
	AK2->(dbSeek(xFilial('AK2')+AK1->(AK1_CODIGO+AK1_VERSAO)))

	While AK2->(!Eof()) .and. AK2->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO) = AK1->(AK1_FILIAL+AK1_CODIGO+AK1_VERSAO)
		RecLock("AK2", .F.)
		AK2->AK2_XSTS := '0'
		AK2->(MsUnLock())
		AK2->(dbSkip())
	Enddo

	RestArea(_aAreaAK2)
Return
