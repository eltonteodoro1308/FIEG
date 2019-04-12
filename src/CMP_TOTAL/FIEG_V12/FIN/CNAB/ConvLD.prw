#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ConvLD
Fun��o para Convers�o da Representa��o Num�rica do C�digo de
Barras - Linha Digit�vel (LD) em C�digo de Barras (CB).

Para utiliza��o dessa Fun��o, deve-se criar um Gatilho para o
campo E2_CODBAR, Conta Dom�nio: E2_CODBAR, Tipo: Prim�rio,
Regra: EXECBLOCK("CONVLD",.T.), Posiciona: N�o.

Utilize tamb�m a Valida��o do Usu�rio para o Campo E2_CODBAR
EXECBLOCK("CODBAR",.T.) para Validar a LD ou o CB.

@type function
@author Fl�vio Novaes
@since 19/10/2003
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Caractere, C�digo de Barras gerado apartir da Linha Digit�vel.

/*/
/*/================================================================================================================================/*/

User Function ConvLD()


	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SETPRVT("cStr")

	cStr := LTrim(RTRIM(M->E2_CODBAR))

	If ValType(M->E2_CODBAR) == NIL .OR. EMPTY(M->E2_CODBAR)
		// Se o Campo est� em Branco n�o Converte nada.
		cStr := ""
	Else
		// Se o Tamanho do String for menor que 44, completa com zeros at� 47 d�gitos. Isso �
		// necess�rio para Bloquetos que N�O t�m o vencimento e/ou o valor informados na LD.
		cStr := If(Len(cStr)<44,cStr+REPL("0",47-Len(cStr)),cStr)
	EndIf

	Do Case
		Case Len(cStr) == 47
		cStr := SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10)
		Case Len(cStr) == 48
		cStr := SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
		OtherWise
		cStr := cStr+Space(48-Len(cStr))
	EndCase

Return(cStr)