#Include "Protheus.ch"

//Constantes
#Define CLR_RGB_BRANCO      RGB(254,254,254)    // Cor Branca em RGB
#Define CLR_RGB_VERMELHO    RGB(255,000,000)    // Cor Vermelha em RGB
#Define CLR_RGB_PRETO       RGB(000,000,000)    // Cor Preta em RGB

/*/================================================================================================================================/*/
/*/{Protheus.doc} MBlkColor
Retorna as cores a serem utilizadas na pintura do browse quando o registro estiver bloqueado.

@type function
@author Thiago Rasmussen
@since 04/10/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Cores a serem utilizadas na pintura do browse quando o registro estiver bloqueado.

/*/
/*/================================================================================================================================/*/

User Function MBlkColor()
	Local aRet := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aAdd(aRet, (CLR_RGB_VERMELHO)) //Cor do texto
	aAdd(aRet, (CLR_RGB_BRANCO)  ) //Cor de fundo

Return aRet