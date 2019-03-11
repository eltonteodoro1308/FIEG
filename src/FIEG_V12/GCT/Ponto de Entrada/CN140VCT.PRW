#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN140VCT
Este ponto de entrada possibilita a revisão ou não para o Contrato, selecionado no painel 3 do wizard.

@type function
@author Thiago Rasmussen
@since 29/11/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/


USER FUNCTION CN140VCT()

	//LOCAL ExpC1 := PARAMIXB[1] // Tipo de Revisão
	//LOCAL ExpC2 := PARAMIXB[2] // Número do Contrato


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//IF Posicione("CN0",1,XFilial("CN0")+ExpC1,"CN0_ESPEC") != '3'
	//	IF CN9->CN9_XMDAQU != 'CP'
	//		MSGALERT("Revisão de " + LOWER(ALLTRIM(Posicione("CN0",1,XFilial("CN0")+ExpC1,"CN0_DESCRI"))) + " só pode ser realizada para contratos de parceria.","CN140VCT")
	//		RETURN .F.
	//	ENDIF
	//ENDIF

Return .T.