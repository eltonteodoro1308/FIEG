#Include "Protheus.ch"

Static cArqSv := ""

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICFGC01
Seleciona o caminho do diret�rio, Consulta padr�o com GetFile.

@type function
@author Renato Lucena Neves
@since 25/08/2011
@version P12.1.23

@param _nOpc, Num�rico, 1 = Retorna o diretorio / 2 = Seleciona o diret�rio.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICFGC01(_nOpc)

	If _nOpc == 1
		Return RetFile()
	Else
		Return GetFile()
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} RetFile
Fun��o de retorno da vari�vel contendo o arquivo ou caminho selecionado para abertura ou grava��o na consulta F3.

@type function
@author Thiago Rasmussen
@since 12/11/2006
@version P12.1.2

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Caractere, Vari�vel contendo o arquivo ou caminho selecionado para abertura ou grava��o na consulta F3.

/*/
/*/================================================================================================================================/*/

Static Function RetFile()
Return cArqSv

/*/================================================================================================================================/*/
/*/{Protheus.doc} GetFile
Getfile para busca de arquivo pela consulta padrao (F3).

@type function
@author Thiago Rasmussen
@since 12/11/2006
@version P12.1.23

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Caractere, Arquivo pela consulta padrao (F3).

/*/
/*/================================================================================================================================/*/

Static Function GetFile()
	//Local cPathIni := GetSrvProfString("RootPath", "")+GetSrvProfString("Startpath", "")

	//+---------------------------------------------------------------------+
	//| Busca local para gravar o arquivo                                   |
	//+---------------------------------------------------------------------+

	cArqSv := cGetFile("","Diretorio para gravacao",1,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY ) //"Local para grava��o..."

Return !Empty(cArqSv)

