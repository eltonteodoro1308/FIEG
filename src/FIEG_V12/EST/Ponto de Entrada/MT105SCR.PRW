#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT105SCR
Ponto de Entrada que disponibiliza o Objeto da dialog para manipulação na opção selecionada (inclusão/ alteração/ visualização/ exclusão ).

@type function
@author Thiago Rasmussen
@since 02/10/2012
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function MT105SCR()
	Local _oDlg		:= ParamIXB[1]
	Local _nOpcx    := ParamIXB[2]
	Local _aArea 	:= GetArea()
	Local _lCopia      := IIF(Type("lCopia") == "U",.f.,lCopia)
	Public _c105CCusto := IIF(_nOpcx==3,Criavar("CP_CC"),SCP->CP_CC)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	@ 005 ,070  SAY OemToAnsi("Centro Custo") PIXEL OF _oDlg
	@ 003 ,105  MSGET _c105CCusto F3 CpoRetF3('CP_CC') VALID CheckSx3("CP_CC",_c105CCusto) WHEN _lCopia .or. (_nOpcx==3 .or. _nOpcx==4) Size 90, 8 PIXEL OF _oDlg

	RestArea(_aArea)
Return()
