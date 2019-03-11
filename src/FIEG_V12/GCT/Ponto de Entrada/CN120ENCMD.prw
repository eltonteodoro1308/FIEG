#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120ENCMD
Ponto executado ap�s o encerramento da medi��o.

@type function
@author Jo�o Renes
@since 21/01/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CN120ENCMD()


	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	LimparCNE()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} LimparCNE
Realiza a exclus�o l�gica do registro, caso CNE_QUANT = 0.

@type function
@author Jo�o Renes
@since 21/01/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Nil, Fun��o sem retorno.

/*/
/*/================================================================================================================================/*/
Static Function LimparCNE()

	Local nStatus := 0

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	nStatus := TCSqlExec("UPDATE CNE010 SET " +;
	"R_E_C_D_E_L_ = R_E_C_N_O_, " +;
	"D_E_L_E_T_ = '*' " +;
	"WHERE CNE_FILIAL = '" + CND->CND_FILIAL + "' AND " +;
	"      CNE_CONTRA = '" + CND->CND_CONTRA + "' AND " +;
	"      CNE_REVISA = '" + CND->CND_REVISA + "' AND " +;
	"      CNE_NUMMED = '" + CND->CND_NUMMED + "' AND " +;
	"      CNE_QUANT = 0")

	IF nStatus < 0
		CONOUT("TCSQLError() " + TCSQLError())
	ENDIF

Return