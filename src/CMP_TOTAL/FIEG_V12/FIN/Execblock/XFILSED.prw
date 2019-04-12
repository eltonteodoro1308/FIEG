#Include "Protheus.ch"
#Include "TopConn.ch"


/*/================================================================================================================================/*/
/*/{Protheus.doc} XFILSED
Fun��o utilizada para filtrar natureza, conforme seu o campo ED_USO.

@type function
@author Thiago Rasmussen
@since 08/09/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Caractere, C�digo do tipo de de uso da natureza conforme programa acessado.

/*/
/*/================================================================================================================================/*/


// Autor....: Thiago Rasmussen
// Data.....: 08/09/2014
// Modulo...: 06 - Financeiro
// Descri��o: Fun��o utilizada para filtrar natureza, conforme seu o campo ED_USO.

User Function XFILSED()

	Local cFiltro := ""


	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DO CASE
		// Contas a Receber e Fun��es de Contas a Receber
		CASE FUNNAME() == "FINA040" .OR. FUNNAME() == "FINA740"
		cFiltro += "1"

		// Contas a Pagar e Fun��es de Contas a Pagar
		CASE FUNNAME() == "FINA050" .OR. FUNNAME() == "FINA750"
		cFiltro += "2"

		// Movimenta��o Banc�ria
		CASE FUNNAME() == "FINA100"
		cFiltro += "3"

		// Documento de Entrada
		CASE FUNNAME() == "MATA103"
		cFiltro += "2"
	ENDCASE

RETURN(cFiltro)