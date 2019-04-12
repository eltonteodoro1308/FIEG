#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110GET
Redimensinar a posicao da GETDADOS, para inclusao do campo C1_XJUSTIF no PE MT110TEL.

@type function
@author Claudinei Ferreira
@since 29/11/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array recebido como parametro com as cordenadas alteradas.

/*/
/*/================================================================================================================================/*/

User Function MT110GET()

	Local _aArea := GetArea()
	Local aRet   := PARAMIXB[1]

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aRet[2,1] := 130 // Posicao inicial da GETDADOS
	aRet[1,3] := 88 // Linha de contorno do cabecalho

	RestArea(_aArea)

Return aRet
