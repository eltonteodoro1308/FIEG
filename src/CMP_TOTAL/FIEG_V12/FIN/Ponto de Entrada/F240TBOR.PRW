#Include "Protheus.ch"
#Include "colors.ch"
#include "rwmake.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F240TBOR
Ponto de Entrada na gravação do bordero que trata o codigo de barras se digitado ou leitora otica no modelo de pagamento tipo 30.

@type function
@author JOSE FERNANDO
@since 25/11/2015
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function F240TBOR()

	Local _aAr :=  getarea()
	Local lRet := .T.

	Private _nTitCon:=0 // 0=Nao identificado;1=Titulo;2=Concessionaria

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cLinhaDig:=space(54)

	DbSelectArea("SE2")

	//IF M->CMODPGTO $ "13;35;91;31;30" .and. M->CPORT240 $ "341"
	IF M->CMODPGTO $ "13;35;91;31;30"

		_cCodBar := se2->e2_codbar

		@ 000,000 TO 225,350 DIALOG oDlg1 TITLE "Entrada de Codigo de Barras do Titulo"

		@ 005,010 SAY "Titulo:"
		@ 005,045 SAY ALLTRIM(se2->e2_prefixo)+"-"+ALLTRIM(se2->e2_num)+"-"+ALLTRIM(se2->e2_parcela)+"-"+ALLTRIM(se2->e2_tipo) COLOR CLR_HBLUE

		@ 015,010 SAY "Fornecedor:"
		@ 015,045 SAY ALLTRIM(se2->e2_nomfor)+" - "+ALLTRIM(se2->e2_fornece) COLOR CLR_HBLUE

		@ 025,010 SAY "Valor R$:"
		@ 025,045 SAY (SE2->E2_SALDO + SE2->E2_ACRESC) - (SE2->E2_DECRESC) size 115 picture "@e 9,999,999.99" COLOR CLR_HBLUE

		@ 040,010 SAY "Passe o documento pela leitora: "
		@ 050,010 GET _cCodBar SIZE 160,50  Valid vazio().or.ECODBAR(_cCodBar,SE2->E2_SALDO)

		@ 065,010 say "Ou informe abaixo a linha digitavel:"
		@ 075,010 get _cLinhaDig size 160,15 valid _fLinhaDig()

		@ 095,100 BMPBUTTON TYPE 01 ACTION (if(GravaBar(),Close(oDlg1),nil))
		@ 095,145 BMPBUTTON TYPE 02 ACTION Close(oDlg1)

		ACTIVATE DIALOG oDlg1 CENTER

		DbSelectArea("SA2")
		SA2->(dbseek(xFilial("SA2")+se2->e2_fornece+se2->e2_loja))

		cBanco  := sa2->a2_banco
		cAg     := SubStr(sa2->a2_agencia,1,4)
		cAgDig  := sa2->a2_xdvage
		cOpera  := sa2->a2_xoperac
		cConta  := sa2->a2_numcon
		cCcDig  := sa2->a2_xdvcta

		if (cBanco = '104' .and. cOpera = ' ') .or. (cBanco = ' ' .or. cAg = ' ' .or. cConta = ' ')

			@ 000,000 TO 210,310 DIALOG oDlg2 TITLE "Cadastro da C/C do Fornecedor"

			@ 005,005 SAY "Dados Bancarios do Fornecedor:: " + sa2->a2_cod + " - " + sa2->a2_nreduz

			@ 017,005 SAY "Cod.Banco"
			@ 017,045 GET cBanco SIZE 17,30

			@ 029,005 SAY "Agencia"
			@ 029,045 GET cAg    SIZE 20,30

			@ 041,005 SAY "Dig Agencia"
			@ 041,045 GET cAgDig SIZE 10,30

			@ 041,080 SAY "Cod.Operacao"
			@ 041,120 GET cOpera SIZE 20,30

			@ 053,005 SAY "C/Corrente"
			@ 053,045 GET cConta SIZE 30,30

			@ 065,005 SAY "Dig C/Corrente"
			@ 065,045 GET cCcDig SIZE 10,30

			@ 077,085 BMPBUTTON TYPE 01 ACTION GravaFor()
			@ 077,120 BMPBUTTON TYPE 02 ACTION Close(oDlg2)

			ACTIVATE DIALOG oDlg2 CENTER
		EndIf
		Restarea(_aAr)

		lRet := .T.

	ELSE

		DbSelectArea("SA2")
		SA2->(dbseek(xFilial("SA2")+se2->e2_fornece+se2->e2_loja))

		cBanco  := sa2->a2_banco
		cAg     := SubStr(sa2->a2_agencia,1,4)
		cAgDig  := sa2->a2_xdvage
		cOpera  := sa2->a2_xoperac
		cConta  := sa2->a2_numcon
		cCcDig  := sa2->a2_xdvcta

		if (cBanco = '104' .and. cOpera = ' ') .or. (cBanco = ' ' .or. cAg = ' ' .or. cConta = ' ')
			@ 000,000 TO 210,310 DIALOG oDlg2 TITLE "Cadastro da C/C do Fornecedor"

			@ 005,005 SAY "Dados Bancarios do Fornecedor:: " + sa2->a2_cod + " - " + sa2->a2_nreduz

			@ 017,005 SAY "Cod.Banco"
			@ 017,045 GET cBanco SIZE 17,30

			@ 029,005 SAY "Agencia"
			@ 029,045 GET cAg    SIZE 20,30

			@ 041,005 SAY "Dig Agencia"
			@ 041,045 GET cAgDig SIZE 10,30

			@ 041,080 SAY "Cod.Operacao"
			@ 041,120 GET cOpera SIZE 20,30

			@ 053,005 SAY "C/Corrente"
			@ 053,045 GET cConta SIZE 30,30

			@ 065,005 SAY "Dig C/Corrente"
			@ 065,045 GET cCcDig SIZE 10,30

			@ 077,085 BMPBUTTON TYPE 01 ACTION GravaFor()
			@ 077,120 BMPBUTTON TYPE 02 ACTION Close(oDlg2)

			ACTIVATE DIALOG oDlg2 CENTER
		EndIf

		Restarea(_aAr)

		lRet := .T.

	EndIf

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} GravaBar
Descrição detalhada da função.

@type function
@author Thiago Rasmussen
@since 13/03/2019
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando que o Código de Barras é válido e foi gravado em E2_CODBAR.

/*/
/*/================================================================================================================================/*/

Static Function GravaBar()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_lReturn:=.f.
	if ECODBAR(_cCodBar,SE2->E2_SALDO)
		RecLock("SE2",.f.)
		SE2->E2_codbar := _cCodBar
		SE2->(MsUnlock())
		_lReturn:=.t.
	endif

Return _lReturn

/*/================================================================================================================================/*/
/*/{Protheus.doc} ECODBAR
Execblock para gatilho para valicao de valor do titulo do contas a pagar x codigo de barras.

@type function
@author Roberto R. Mezzalira
@since 19/01/2006
@version P12.1.23

@param CodBar, Caractere, Código de Barras
@param nVLRTIT, Numérico, Valor do Título

@obs Projeto ELO alterado pela FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando a valicao de valor do titulo do contas a pagar x codigo de barras.

/*/
/*/================================================================================================================================/*/

Static Function ECODBAR(CodBar,nVLRTIT)

	Local   _aArea   :=  getarea()
	//Local   _cBco    :=  Substr(CODBAR,1,3) //IDENTIFICA O BANCO DO CODIGO DE BARRA
	LOCAL   _nVlr    :=  0  // RETORNA O VALOR DO CODIGO DE BARRA
	LOCAL   _cVlr    :=  ""
	LOCAL 	_cVlrtit :=  ""
	Private _Lok   := .F.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_nTitCon:=0 // 0=Nao identificado;1=Titulo;2=Concessionaria

	if left(codbar,1)=="8"
		_nTitCon:=2
		_nVlr := (VAL(Substr(CODBAR,6,10))/100)
	else
		_nTitCon:=1
		// _nVlr := (VAL(Substr(CODBAR,10,10))/100)
		_nVlr := (VAL(Substr(CODBAR,12,10))/100)
	endif


	//   _cVlr    := PADR(ALLTRIM(transform((_nVlr),"@E 999,999,999.99")),18)
	_cVlr    := PADR(transform(_nVlr,"@E 99,999,999.99"),18)
	_cVlrtit := PADR(ALLTRIM(transform(SE2->E2_SALDO,"@E 99,999,999.99")),18)

	IF _cVlrtit <> _cVlr  .And. CODBAR <> " "

		MsgInfo("Valor do titulo R$ "+_cVlr+CHR(13)+" Difere do Titulo R$ "+_cVlrtit+CHR(13)+CHR(13)+"Cancele a operacao e encontre o titulo correto"+CHR(13),"Boleto invalido")
		_Lok   := .F.
	ELSE
		_Lok   := .T.
	ENDIF

	Restarea(_aArea)

Return(_Lok)

/*/================================================================================================================================/*/
/*/{Protheus.doc} GravaFor
Grava dados do Fornecedor.

@type function
@author Thiago Rasmussen
@since 13/03/2019
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GravaFor()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	RecLock("SA2",.f.)

	sa2->a2_banco   := cBanco
	sa2->a2_agencia := cAg
	sa2->a2_xoperac := cOpera
	sa2->a2_numcon  := cConta
	sa2->a2_xdvcta  := cCcDig
	sa2->a2_xdvage  := cAgDig

	sa2->(MsUnlock())

	Close(oDlg2)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fLinhaDig
Monta o codigo de barras a partir da linha digitavel.

@type function
@author Ricardo Luiz da Rocha
@since 24/04/2006
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo verdadeiro.

/*/
/*/================================================================================================================================/*/

Static Function _fLinhaDig()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cReturn:=_cBarraAux:=""
	for _nVez:=1 to len(_cLinhaDig)
		_cLido:=substr(_cLinhadig,_nVez,1)
		if _cLido$'0123456789'
			_cReturn+=_cLido
		endif
	next

	_nTitCon:=0 // 0=Nao identificado;1=Titulo;2=Concessionaria

	if left(_cReturn,1)=="8"
		_nTitCon:=2
	else
		_nTitCon:=1
	endif

	if _nTitCon==1 // Titulo normal
		if !empty(_cReturn)
			if len(alltrim(_cReturn))<=38
				_cReturn:=SubStr(_cReturn,1,33)+StrZero(ABS(se2->e2_saldo*100),14)
				Return
			endif

			if Substr(_cReturn,34,5) == "00000" .and. Len(alltrim(_cReturn)) == 47  // Fator de Vencimento
				_cReturn:=SubStr(_cReturn,1,33)+StrZero(ABS(se2->e2_saldo*100),14)
			else
				_cReturn:=SubStr(_cReturn,1,38)+StrZero(ABS(se2->e2_saldo*100),09)
			endif

			if substr(_cReturn,34,5) <> "00000"
				nVal1 := strzero(abs(se2->e2_saldo*100),14)
				nVal  := substr(_cReturn,34,5)+substr(nVal1,6,9)
				_cBarraAux:= substr(_cReturn,1,4)+nVal+substr(_cReturn,5,5)+substr(_cReturn,11,10)+substr(_cReturn,22,10)
				MsgInfo("final com zeros >>"+_cBarraAux)
			else
				_cBarraAux:= substr(_cReturn,1,4)+strzero(abs(se2->e2_saldo*100),14)+substr(_cReturn,5,5)+substr(_cReturn,11,10)+substr(_cReturn,22,10)
				MsgInfo("final sem zeros >>"+_cBarraAux)
			endif

			_cReturn:=substr(_cBarraAux,1,4) + substr(_cReturn,33,1) + substr(_cBarraAux,5,39)
			_cCodBar:=_cReturn
		endif
	elseif _nTitCon==2 // Concessionaria
		if !empty(_cReturn)
			_cReturn:=substr(_cReturn,01,11)+;
			substr(_cReturn,13,11)+;
			substr(_cReturn,25,11)+;
			substr(_cReturn,37,11)
			_cCodBar:=_cReturn
			MsgInfo("Concessionaria >>"+_cCodBar)
		endif
	endif

return .t.