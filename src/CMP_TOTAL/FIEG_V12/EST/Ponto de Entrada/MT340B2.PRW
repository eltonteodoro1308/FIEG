#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT340B2
Ponto de entrada para atualizar status do inventário para 3 após geração do ajuste de inventário.

@type function
@author Leonardo Soncin
@since 06/12/2011
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function MT340B2

	//+---------------------------------------------------------------------+
	//| Declaracao de Variaveis                                             |
	//+---------------------------------------------------------------------+
	Local aArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SB7SQL->(DBGOTOP())  //Incluído por Ana
	dbSelectArea("SB7")
	SB7->(dbSetOrder(1))
	//MsSeek(xFilial("SB7")+dtos(SB7SQL->B7_DATA)+SB7SQL->B7_COD+SB7SQL->B7_LOCAL+SB7SQL->B7_LOCALIZ+SB7SQL->B7_NUMSERI+SB7SQL->B7_LOTECTL+SB7SQL->B7_NUMLOTE)
	SB7->(MsSeek(xFilial("SB7")+dtos(SB7SQL->B7_DATA)))

	While  SB7->( ! Eof() ) .AND. (SB7->B7_FILIAL+Dtos(SB7->B7_DATA))== ;//+SB7->B7_COD+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_NUMSERI+SB7->B7_LOTECTL+SB7->B7_NUMLOTE)== ;
	(xFilial("SB7")+dtos(SB7SQL->B7_DATA))//+SB7SQL->B7_COD+SB7SQL->B7_LOCAL+SB7SQL->B7_LOCALIZ+SB7SQL->B7_NUMSERI+SB7SQL->B7_LOTECTL+SB7SQL->B7_NUMLOTE)

		If SB7->B7_XORIGEM $ 'SIESTA01' .and. SB7->B7_COD >= MV_PAR05 .AND. SB7->B7_COD <= MV_PAR06 .And. ;
		SB7->B7_LOCAL >= MV_PAR07 .AND. SB7->B7_LOCAL <= MV_PAR08 .And. ;
		SB7->B7_DOC >= MV_PAR11 .AND. SB7->B7_DOC <= MV_PAR12
			dbSelectArea("SZK")
			SZK->(dbSetORder(1))
			If SZK->(dbSeek(xFilial("SZK")+SB7->B7_DOC))
				If SZK->ZK_STATUS <> '3'
					RecLock("SZK",.F.)
					SZK->ZK_STATUS := "3"
					SZK->(MsUnLock())
				Endif
			Endif
		Endif

		dbSelectArea("SB7")
		SB7->(dbSkip())
	Enddo

	RestArea(aArea)
Return