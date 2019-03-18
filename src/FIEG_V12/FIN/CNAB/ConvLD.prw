#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ConvLD
Função para Conversão da Representação Numérica do Código de
Barras - Linha Digitável (LD) em Código de Barras (CB).

Para utilização dessa Função, deve-se criar um Gatilho para o
campo E2_CODBAR, Conta Domínio: E2_CODBAR, Tipo: Primário,
Regra: EXECBLOCK("CONVLD",.T.), Posiciona: Não.

Utilize também a Validação do Usuário para o Campo E2_CODBAR
EXECBLOCK("CODBAR",.T.) para Validar a LD ou o CB.

@type function
@author Flávio Novaes
@since 19/10/2003
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Código de Barras gerado apartir da Linha Digitável.

/*/
/*/================================================================================================================================/*/

User Function ConvLD()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SETPRVT("cStr")

	cStr := LTrim(RTRIM(M->E2_CODBAR))

	If ValType(M->E2_CODBAR) == NIL .OR. EMPTY(M->E2_CODBAR)
		// Se o Campo está em Branco não Converte nada.
		cStr := ""
	Else
		// Se o Tamanho do String for menor que 44, completa com zeros até 47 dígitos. Isso é
		// necessário para Bloquetos que NÂO têm o vencimento e/ou o valor informados na LD.
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