#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT106SC1
Gravacao de das entidades contabeis da SA para SC.

@type function
@author Thiago Rasmussen
@since 03/10/2011
@version P12.1.23

@obs Projeto ELO

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function MT106SC1()

	Local _aArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	RecLock("SC1",.f.)
	If SC1->(FieldPos("C1_EC05DB")) > 0 .And. SCP->(FieldPos("CP_EC05DB")) > 0
		SC1->C1_EC05DB	:= SCP->CP_EC05DB
	EndIf
	If SC1->(FieldPos("C1_EC05CR")) > 0 .And. SCP->(FieldPos("CP_EC05CR")) > 0
		SC1->C1_EC05CR	:= SCP->CP_EC05CR
	EndIf
	If SC1->(FieldPos("C1_EC06DB")) > 0 .And. SCP->(FieldPos("CP_EC06DB")) > 0
		SC1->C1_EC06DB	:= SCP->CP_EC06DB
	EndIf
	If SC1->(FieldPos("C1_EC06CR")) > 0 .And. SCP->(FieldPos("CP_EC06CR")) > 0
		SC1->C1_EC06CR	:= SCP->CP_EC06CR
	EndIf
	If SC1->(FieldPos("C1_EC07DB")) > 0 .And. SCP->(FieldPos("CP_EC07DB")) > 0
		SC1->C1_EC07DB	:= SCP->CP_EC07DB
	EndIf
	If SC1->(FieldPos("C1_EC07CR")) > 0 .And. SCP->(FieldPos("CP_EC07CR")) > 0
		SC1->C1_EC07CR	:= SCP->CP_EC07CR
	EndIf
	If SC1->(FieldPos("C1_EC08DB")) > 0 .And. SCP->(FieldPos("CP_EC08DB")) > 0
		SC1->C1_EC08DB	:= SCP->CP_EC08DB
	EndIf
	If SC1->(FieldPos("C1_EC08CR")) > 0 .And. SCP->(FieldPos("CP_EC08CR")) > 0
		SC1->C1_EC08CR	:= SCP->CP_EC08CR
	EndIf
	If SC1->(FieldPos("C1_EC09DB")) > 0 .And. SCP->(FieldPos("CP_EC09DB")) > 0
		SC1->C1_EC09DB	:= SCP->CP_EC09DB
	EndIf
	If SC1->(FieldPos("C1_EC09CR")) > 0 .And. SCP->(FieldPos("CP_EC09CR")) > 0
		SC1->C1_EC09CR	:= SCP->CP_EC09CR
	EndIf

	// Atualizacao do campo prefixo da conta (C1_PREFIX)
	CT1->(dbSetOrder(1))
	IF CT1->(FieldPos("CT1_PREFIX")) > 0 .and. CT1->(dbSeek(xFilial("CT1")+SC1->C1_CONTA))
		SC1->C1_PREFIX := CT1->CT1_PREFIX
	ENDIF

	// Valor Unitário E Total
	SC1->C1_VUNIT := SCP->CP_XVUNIT
	SC1->C1_PRECO := SCP->CP_XVLRTOT

	// Comprador do Grupo
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(XFilial("SB1")+SC1->C1_PRODUTO))

	SBM->(dbSetOrder(1))
	IF SBM->(FieldPos("BM_XCOD")) > 0 .and. SBM->(dbSeek(XFiliaL("SBM")+SB1->B1_GRUPO))
		SC1->C1_XCODCOM := SBM->BM_XCOD
	ENDIF

	// Tipo da Solicitacao
	SC1->C1_TPSC := CriaVar("C1_TPSC")

	SC1->(MsUnLock())

	RestArea(_aArea)

Return
