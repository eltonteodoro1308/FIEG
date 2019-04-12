#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIFINC01
Mostra resumo de titulos marcados no bordero .

@type function
@author Thiago Rasmussen
@since 29/03/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIFINC01()
	Local _cArea   := GetArea()
	Local _aTitulo := {}


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	(Alias())->(dbGoTop())

	While (Alias())->(!Eof())
		// Verifica se esta marcado
		IF !Empty((Alias())->E2_OK)
			IF ( _nPos := Ascan(_aTitulo,{ |x| x[1] == (Alias())->E2_FORNECE .and. x[2] == (Alias())->E2_LOJA } ) ) > 0
				_aTitulo[_nPos,4] += (Alias())->E2_SALDO
			ELSE
				Aadd(_aTitulo,{ (Alias())->E2_FORNECE,(Alias())->E2_LOJA,(Alias())->E2_NOMFOR,(Alias())->E2_SALDO })
			ENDIF
		ENDIF
		(Alias())->(dbSkip())
	Enddo

	// Verifica se existem titulos marcados
	IF Len(_aTitulo) == 0
		MsgInfo("Nenhum título for marcado.")
	ELSE

		DEFINE MSDIALOG oDlgTit TITLE "Total por Fornecedor" FROM 0,0 TO 300,450 PIXEL

		@ 10,10 LISTBOX oLbx FIELDS HEADER "Código","Loja","Nome Fornecedor","Total" SIZE 382,120 OF oDlgTit PIXEL

		oLbx:SetArray( _aTitulo )
		oLbx:bLine := {|| {_aTitulo[oLbx:nAt,1],_aTitulo[oLbx:nAt,2],_aTitulo[oLbx:nAt,3],Transform(_aTitulo[oLbx:nAt,4],PesqPict("SE2","E2_SALDO",,2))}}

		oLbx:Align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlgTit ON INIT (EnchoiceBar(oDlgTit,{|| oDlgTit:End() },{|| oDlgTit:End() })) CENTERED

	ENDIF

	RestArea(_cArea)

Return()
