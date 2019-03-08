#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA16
Funcao para gravar campo C1_CODCOMP da SC.

@type function
@author Claudinei Ferreira
@since 17/01/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA16

	Local _aArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If (INCLUI .or. ALTERA) .AND. ( SC1->(!EOF()))
		Reclock("SC1",.F.)
		SC1->C1_CODCOMP := C1_XCODCOMP
		SC1->( MsUnlock() )
	Endif

	RestArea(_aArea)

Return