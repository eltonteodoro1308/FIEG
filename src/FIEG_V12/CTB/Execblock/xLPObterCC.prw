#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} xLPObterCC
No caso das filiais matriz de cada uma das empresas, assumir o centro de custo "000999".

@type function
@author Thiago Rasmussen
@since 15/04/2014
@version P12.1.23

@param _Filial, Caractere, Código da Filial.
@param _CC, Caractere, Código do Centro de Custo.
@param _PREFIXO, Caractere, Prefixo a ser considerado na consulta.

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Código do Centro de Custo.

/*/
/*/================================================================================================================================/*/

User Function xLPObterCC(_Filial,_CC,_PREFIXO)

	Local cRet := ''

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DO CASE
		// FIEG
		CASE _FILIAL == "01GO0001"
			If (( Empty(_PREFIXO) .OR. AT(ALLTRIM(_PREFIXO) + ";","DD;RP;") == 0 ) .AND. AT(ALLTRIM(_CC)+";", "000001;000002;000003;000004;000005;000006;000007;000008;000009;000010;000011;000012;000013;000014;000015;000016;000017;000018;000019;000020;000021;000022;000023") > 0 )
				cRet := "000999"
			Else
				cRet := Alltrim(_CC)
			EndIf
		// SESI
		CASE _FILIAL == "02GO0001"
			If (( Empty(_PREFIXO) .OR. AT(ALLTRIM(_PREFIXO) + ";","DD;RP;") == 0 ) .AND. AT(ALLTRIM(_CC)+";", "000001;000002;000003;000004;000005;000006;000007;000008;000009;000010;000011;000012;000013;000014;000015;000016;000017;000018;000019;000020;000021;000022;000023;000024;") > 0 )
				cRet := "000999"
			Else
				cRet := Alltrim(_CC)
			EndIf
		// SENAI
		CASE _FILIAL == "03GO0001"
			If (( Empty(_PREFIXO) .OR. AT(ALLTRIM(_PREFIXO) + ";","DD;RP;") == 0 ) .AND. AT(ALLTRIM(_CC)+";", "000001;000002;000003;000004;000005;000006;000007;000008;000009;000010;000011;000012;000013;000014;000015;000016;000017;000018;000019;000020;000021;000022;") > 0 )
				cRet := "000999"
			Else
				cRet := Alltrim(_CC)
			EndIf
		// IEL
		CASE _FILIAL == "04GO0001"
			If (( Empty(_PREFIXO) .OR. AT(ALLTRIM(_PREFIXO) + ";","DD;RP;") == 0 ) .AND. AT(ALLTRIM(_CC)+";", "000001;000002;000003;000004;000005;000006;000007;000008;000009;000010;000011;000012;000013;000014;000015;000016;000017;000018;000019;000020;000021;000022;000023;000024;000025;000026;000027;000028;000029;") > 0 )
				cRet := "000999"
			Else
				cRet := Alltrim(_CC)
			EndIf
		// ICQ-BRASIL
		CASE _FILIAL == "05GO0001"
			If (( Empty(_PREFIXO) .OR. AT(ALLTRIM(_PREFIXO) + ";","DD;RP;") == 0 ) .AND. AT(ALLTRIM(_CC)+";", "000001;000002;000003;000004;000005;000006;000007;000008;000009;000010;000011;000012;000013;000014;000015;000016;000017;") > 0 )
				cRet := "000999"
			Else
				cRet := Alltrim(_CC)
			EndIf
	EndCase

Return cRet