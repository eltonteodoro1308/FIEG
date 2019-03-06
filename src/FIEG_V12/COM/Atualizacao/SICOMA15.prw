#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA15
Rotina para filtrar campo C1_CODCOMP para Cotacao/Licitacao.

@type function
@author Claudinei Ferreira
@since 16/01/2012
@version P12.1.23

@param cNmPE, Caractere, descricao

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Caractere, Condi��o ADVPl que define o Filtro.

/*/
/*/================================================================================================================================/*/

User Function SICOMA15(cNmPE)

	Local _aArea	:= GetArea()
	Local _aAreaSY1	:= SY1->(GetArea())
	Local lFilSC1	:= SuperGetMV('MV_XFILTRO')
	Local cFilSC1	:= ''
	Local cCodComp	:= ''


	If lFilSC1

		cCodComp	:= Posicione('SY1',3,xFilial('SY1')+__CUSERID,'Y1_COD')

		//+---------------------------------------+
		//|Tratamento para rotina de Gerar Edital |
		//+---------------------------------------+
		If cNmPE == 'GCP02FIL'
			cFilSC1 := " AND C1_CODCOMP ='" + cCodComp + "' AND SC1.C1_XCONTPR = ' '"
		Else
			//cFilSC1 := " C1_CODCOMP ='" + cCodComp + "' .And. C1_TPSC = '1'" //Alterado por Cadu em 18/07/2012
			cFilSC1 := " C1_CODCOMP == '" + cCodComp + "'" //Alterado por Cadu em 18/07/2012
		Endif
	Endif

	//Desc. Ponto de entrada incluir filtro na licita��o, n�o permitir
	//mostrar solicita��es com vinculo com contrato de registro de pre�o

	//cFilSC1  += " AND SC1.C1_XCONTPR = ' ' " // FSW - N�O SER VINCULADO AO CONTRATO DE REGISTRO DE PRE�O

	//Ajustado por Cadu em 18/07/2012 - O filtro da SC de licita��o na cotacao independe do filtro do fornecedor

	If cNmPE <> 'GCP02FIL'
		If Empty(cFilSC1)
			cFilSC1 := " C1_TPSC = '1' "
		Else
			cFilSC1 += " .And. C1_TPSC = '1' "
		EndIf
	EndIf

	RestArea(_aAreaSY1)
	RestArea(_aArea)

Return(cFilSC1)
